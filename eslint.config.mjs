import templEslintConfig from '@templ-project/eslint';

export default [
  {
    ignores: [
      '.venv/**',
      'dist/**',
      'coverage/**',
      'docs-html/**',
      'package.json',
      'package-lock.json',
      'tsconfig.json',
      'jsconfig.json',
    ],
  },
  ...templEslintConfig,
];
