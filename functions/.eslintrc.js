module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'google',
  ],
  rules: {
    'quotes': ['error', 'single'],
    'indent': ['error', 2],
    'max-len': ['error', {'code': 100}],
    'require-jsdoc': 'off',
  },
  parserOptions: {
    ecmaVersion: 2020,
  },
};

