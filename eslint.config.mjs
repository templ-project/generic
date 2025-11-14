import templEslintConfig from '@templ-project/eslint';

export default [
  {
    ignores: [
      '.venv/**',
      'dist/**',
      'coverage/**',
      'docs-html/**',
      '.jscpd/**',
      'node_modules/**',
      '**/*.config.js',
      '**/*.config.cjs',
      '**/*.config.mjs',
      'package.json',
      'package-lock.json',
      '.gitignore',
      '.prettierignore',
      '.eslintignore',
      'LICENSE',
      'tsconfig.json',
      'jsconfig.json',
    ],
  },
  ...templEslintConfig,
];
