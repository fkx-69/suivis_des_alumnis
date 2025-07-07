// tailwind.config.ts or .js
import type { Config } from 'tailwindcss'

module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx}',
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
  ],
  plugins: [require('daisyui')],
  daisyui: {
    themes: ["itma", "itma-dark"], // Use our two custom themes
  },
};
