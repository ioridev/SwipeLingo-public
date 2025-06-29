const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// 多言語対応のメッセージテンプレート
const messages = {
  ja: {
    dailyReminder: 'SwipeLingoで楽しく学習しましょう！',
    reviewCards: (count) => `${count}枚のカードが復習時期です`,
    streak: (days) => `${days}日連続達成中！今日も頑張りましょう🔥`,
    newVideos: (category) => `「${category}」の新しい動画が追加されました`,
    welcomeBack: 'お帰りなさい！学習を再開しましょう',
    milestone: (achievement) => `素晴らしい！${achievement}を達成しました🎉`,
  },
  en: {
    dailyReminder: 'Time to learn with SwipeLingo!',
    reviewCards: (count) => `${count} cards are ready for review`,
    streak: (days) => `${days} day streak! Keep it up 🔥`,
    newVideos: (category) => `New videos added in "${category}"`,
    welcomeBack: 'Welcome back! Let\'s continue learning',
    milestone: (achievement) => `Amazing! You achieved ${achievement} 🎉`,
  },
};

// ユーザーの言語設定を取得
const getUserLanguage = (userSettings) => {
  return userSettings?.language || 'ja';
};

// メッセージを取得
const getMessage = (language, messageType, ...args) => {
  const langMessages = messages[language] || messages.ja;
  const messageFunc = langMessages[messageType];

  if (typeof messageFunc === 'function') {
    return messageFunc(...args);
  }
  return messageFunc || langMessages.dailyReminder;
};

// 1. ユーザーの学習パターンを分析（毎日深夜2時実行）
exports.analyzeUserPattern = functions.pubsub
  .schedule('0 2 * * *')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    console.log('Starting user pattern analysis...');

    try {
      const now = admin.firestore.Timestamp.now();
      const sevenDaysAgo = new Date(now.toDate().getTime() - 7 * 24 * 60 * 60 * 1000);

      let lastDocId = null;
      let hasMore = true;
      let totalAnalyzed = 0;
      const batchSize = 100; // バッチサイズを設定

      while (hasMore) {
        // ユーザーをバッチで取得
        let query = db.collection('users')
          .orderBy(admin.firestore.FieldPath.documentId())
          .limit(batchSize);

        if (lastDocId) {
          query = query.startAfter(lastDocId);
        }

        const usersSnapshot = await query.get();

        if (usersSnapshot.empty) {
          hasMore = false;
          break;
        }

        const updatePromises = [];

        for (const userDoc of usersSnapshot.docs) {
          const userId = userDoc.id;
          lastDocId = userId;

          // 過去7日間の学習履歴を取得
          const historySnapshot = await db.collection('users').doc(userId)
            .collection('daily_stats')
            .where('date', '>=', sevenDaysAgo)
            .get();

          if (historySnapshot.empty) {
            continue;
          }

          // 時間帯別の学習頻度を分析
          const hourlyActivity = new Array(24).fill(0);

          historySnapshot.forEach((doc) => {
            const data = doc.data();
            if (data.lastActiveTime) {
              const hour = data.lastActiveTime.toDate().getHours();
              hourlyActivity[hour]++;
            }
          });

          // 最も活発な時間帯を特定
          let maxActivity = 0;
          let preferredHour = 20; // デフォルト: 20時

          for (let hour = 6; hour < 23; hour++) { // 6時から22時の間で検索
            if (hourlyActivity[hour] > maxActivity) {
              maxActivity = hourlyActivity[hour];
              preferredHour = hour;
            }
          }

          // ユーザー設定を更新
          updatePromises.push(
            db.collection('users').doc(userId).update({
              'settings.preferredNotificationTime':
                `${preferredHour.toString().padStart(2, '0')}:00`,
              'settings.lastPatternAnalysis': now,
            }),
          );
        }

        // バッチごとに更新を実行
        await Promise.all(updatePromises);
        totalAnalyzed += updatePromises.length;

        // バッチ処理の進捗をログ出力
        console.log(`Processed batch: ${updatePromises.length} users`);

        // 次のバッチまで少し待機（レート制限対策）
        if (hasMore) {
          await new Promise((resolve) => setTimeout(resolve, 100));
        }
      }

      console.log(`Total analyzed: ${totalAnalyzed} users`);
    } catch (error) {
      console.error('Error analyzing user patterns:', error);
    }

    return null;
  });

// 2. 毎時実行：該当時間のユーザーに通知を送信
exports.sendDailyReminders = functions.pubsub
  .schedule('0 * * * *')
  .onRun(async (context) => {
    console.log('Checking for scheduled reminders...');

    try {
      const now = new Date();
      const currentHour = now.getHours().toString().padStart(2, '0');
      const currentTime = `${currentHour}:00`;

      // この時間に通知予定のユーザーを取得
      const usersSnapshot = await db.collection('users')
        .where('settings.notificationEnabled', '==', true)
        .where('settings.preferredNotificationTime', '==', currentTime)
        .get();

      if (usersSnapshot.empty) {
        console.log('No users scheduled for this hour');
        return null;
      }

      const notificationPromises = [];

      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const userSettings = userData.settings || {};
        const language = getUserLanguage(userSettings);

        // デイリーリマインダーが有効かチェック
        const notificationTypes = userSettings.notificationTypes || {};
        if (notificationTypes.daily === false) {
          console.log(`Daily reminder disabled for user ${userId}`);
          continue;
        }

        // FCMトークンを取得
        const fcmToken = userData.fcmToken;
        if (!fcmToken) {
          console.log(`No FCM token for user ${userId}`);
          continue;
        }

        // 学習統計を取得（現在は未使用）

        // 復習が必要なカードの数を取得
        const cardsSnapshot = await db.collection('users').doc(userId)
          .collection('cards')
          .where('nextReviewDate', '<=', admin.firestore.Timestamp.now())
          .limit(50)
          .get();

        const reviewCount = cardsSnapshot.size;

        // メッセージを決定
        const title = 'SwipeLingo';
        let body = getMessage(language, 'dailyReminder');
        const data = {
          type: 'daily',
          deepLink: '/home',
        };

        // 連続学習日数を確認
        if (userData.currentStreak && userData.currentStreak > 0) {
          body = getMessage(language, 'streak', userData.currentStreak);
          data.type = 'streak';
          data.streak = userData.currentStreak.toString();
        }

        // 復習カードがある場合
        if (reviewCount > 0) {
          body = getMessage(language, 'reviewCards', reviewCount);
          data.type = 'review';
          data.cardCount = reviewCount.toString();
          data.deepLink = '/flashcards?mode=review';
        }

        // 通知を送信
        const message = {
          token: fcmToken,
          notification: {
            title: title,
            body: body,
          },
          data: data,
          android: {
            priority: 'high',
            notification: {
              channelId: 'daily_reminder',
            },
          },
          apns: {
            headers: {
              'apns-priority': '10',
            },
            payload: {
              aps: {
                badge: reviewCount > 0 ? reviewCount : undefined,
                sound: 'default',
              },
            },
          },
        };

        notificationPromises.push(
          messaging.send(message)
            .then(() => {
              console.log(`Notification sent to user ${userId}`);
              // 最終通知時刻を更新
              return db.collection('users').doc(userId).update({
                'settings.lastNotificationTime': admin.firestore.Timestamp.now(),
              });
            })
            .catch((error) => {
              console.error(`Failed to send notification to user ${userId}:`, error);
            }),
        );
      }

      await Promise.all(notificationPromises);
      console.log(`Sent ${notificationPromises.length} notifications`);
    } catch (error) {
      console.error('Error sending daily reminders:', error);
    }

    return null;
  });

// 3. 4時間ごとに復習カードをチェック
exports.checkReviewCards = functions.pubsub
  .schedule('0 */4 * * *')
  .onRun(async (context) => {
    console.log('Checking review cards...');

    try {
      const usersSnapshot = await db.collection('users')
        .where('settings.notificationEnabled', '==', true)
        .where('settings.notificationTypes.review', '==', true)
        .get();

      const notificationPromises = [];

      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const userSettings = userData.settings || {};
        const language = getUserLanguage(userSettings);

        const fcmToken = userData.fcmToken;
        if (!fcmToken) continue;

        // 最後の通知から最低4時間経過しているか確認
        const lastNotification = userSettings.lastNotificationTime;
        if (lastNotification) {
          const fourHoursAgo = new Date(Date.now() - 4 * 60 * 60 * 1000);
          if (lastNotification.toDate() > fourHoursAgo) {
            continue;
          }
        }

        // 期限切れのカードを確認
        const overdueSnapshot = await db.collection('users').doc(userId)
          .collection('cards')
          .where('nextReviewDate', '<=', admin.firestore.Timestamp.now())
          .orderBy('nextReviewDate', 'asc')
          .limit(20)
          .get();

        if (overdueSnapshot.empty) continue;

        // 最も古いカードの遅延日数を計算
        const oldestCard = overdueSnapshot.docs[0].data();
        const daysOverdue = Math.floor(
          (Date.now() - oldestCard.nextReviewDate.toDate().getTime()) / (1000 * 60 * 60 * 24),
        );

        // 優先度を決定
        let priority = 'normal';
        if (daysOverdue >= 3) priority = 'high';
        else if (daysOverdue >= 1) priority = 'normal';
        else priority = 'low';

        // 高優先度の場合のみ通知
        if (priority === 'high' || (priority === 'normal' && overdueSnapshot.size >= 10)) {
          const message = {
            token: fcmToken,
            notification: {
              title: 'SwipeLingo',
              body: getMessage(language, 'reviewCards', overdueSnapshot.size),
            },
            data: {
              type: 'urgent_review',
              cardCount: overdueSnapshot.size.toString(),
              priority: priority,
              deepLink: '/flashcards?mode=review',
            },
            android: {
              priority: 'high',
              notification: {
                channelId: 'review_reminder',
                priority: priority === 'high' ? 'max' : 'high',
              },
            },
            apns: {
              headers: {
                'apns-priority': '10',
              },
              payload: {
                aps: {
                  'badge': overdueSnapshot.size,
                  'sound': 'default',
                  'interruption-level': priority === 'high' ? 'critical' : 'active',
                },
              },
            },
          };

          notificationPromises.push(
            messaging.send(message)
              .then(() => {
                console.log(`Urgent review notification sent to user ${userId}`);
                return db.collection('users').doc(userId).update({
                  'settings.lastNotificationTime': admin.firestore.Timestamp.now(),
                });
              })
              .catch((error) => {
                console.error(`Failed to send review notification to user ${userId}:`, error);
              }),
          );
        }
      }

      await Promise.all(notificationPromises);
      console.log(`Sent ${notificationPromises.length} review notifications`);
    } catch (error) {
      console.error('Error checking review cards:', error);
    }

    return null;
  });

