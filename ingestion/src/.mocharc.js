'use strict';

// Here's a JavaScript-based config file.
// If you need conditional logic, you might want to use this type of config.
// Otherwise, JSON or YAML is recommended.

module.exports = {
  diff: true,
  extension: ['ts'],
  package: './package.json',
  reporter: 'spec',
  slow: 75,
  timeout: 2000,
  require: '@babel/register',
  require: 'ts-node/register',
  'watch-files': ['lib/**/*.js', 'test//*.ts'],
  'watch-ignore': ['lib/vendor']
};