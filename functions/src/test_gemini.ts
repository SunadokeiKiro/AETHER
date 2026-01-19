import { GoogleGenerativeAI } from '@google/generative-ai';
import * as dotenv from 'dotenv';
dotenv.config();

async function testGemini() {
    console.log('Testing Gemini API...');
    const key = process.env.GEMINI_API_KEY;
    if (!key) {
        console.error('Error: GEMINI_API_KEY is missing in .env');
        return;
    }
    console.log(`API Key found (length: ${key.length})`);

    const modelsToTry = ['gemini-1.5-flash', 'gemini-1.5-flash-001', 'gemini-pro', 'gemini-1.0-pro'];
    const genAI = new GoogleGenerativeAI(key);

    for (const modelName of modelsToTry) {
        console.log(`\nTesting model: ${modelName}...`);
        try {
            const model = genAI.getGenerativeModel({ model: modelName });
            const result = await model.generateContent('Hello');
            console.log(`Success with ${modelName}! Response:`, result.response.text());
            return; // Exit on first success
        } catch (error: any) {
            console.error(`Failed with ${modelName}: Status ${error.status} - ${error.statusText}`);
            if (error.errorDetails) {
                console.error('Details:', JSON.stringify(error.errorDetails));
            }
        }
    }
}

testGemini();
