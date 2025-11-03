export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.status(200).json({
    powerups: {
      double_stars_5_questions: { price: 100, discounted: false },
      triple_stars_5_questions: { price: 180, discounted: false },
      five_times_stars_5_questions: { price: 350, discounted: true },
      double_stars_60_seconds: { price: 120, discounted: false },
    },
    themes: {
      oled: { price: 150, discounted: false },
      green: { price: 120, discounted: false },
      orange: { price: 120, discounted: false },
    },
    ai_theme_generator: { price: 200, discounted: true },
  });
}
