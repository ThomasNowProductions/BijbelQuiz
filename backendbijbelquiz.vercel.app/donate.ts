import express, { Request, Response } from 'express';
import path from 'path';

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files from the public directory
app.use(express.static('public'));

// Redirect route
app.get('/donate', (req: Request, res: Response) => {
    res.redirect(301, 'https://tikkie.me/pay/hrl9k9g0h7o7u207ih6o');
});

// Serve the HTML page (optional, if you want to keep the redirect message)
app.get('/donate-page', (req: Request, res: Response) => {
    res.sendFile(path.join(__dirname, 'public', 'donate.html'));
});
// Keep compatibility with requests for the source file path
app.get('/donate.ts', (req: Request, res: Response) => {
    // Redirect legacy/incorrect requests to the working /donate route
    res.redirect(301, '/donate');
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
