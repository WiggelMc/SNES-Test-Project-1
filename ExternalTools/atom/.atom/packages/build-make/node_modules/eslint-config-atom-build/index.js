module.exports = {
  'extends': [
    'atom-build/possible-errors',
    'atom-build/best-practices',
    'atom-build/strict-mode',
    'atom-build/variables',
    'atom-build/node-js-common-js',
    'atom-build/stylistic-issues',
    'atom-build/ecmascript-6',
  ],
  'env': {
    'es6': true,
    'node': true,
    'browser': true,
    'jasmine': true
  },
  'globals': {
    'atom': true,
    'waitsForPromise': true,
    'fit': false,
    'fdescribe': false
  },
};
