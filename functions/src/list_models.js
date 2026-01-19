require('dotenv').config();

async function listModels() {
    const key = process.env.GEMINI_API_KEY;
    console.log(`Checking key: ${key ? 'Present' : 'Missing'}, Length: ${key?.length}`);

    const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${key}`;

    console.log(`GET ${url.replace(key, '***')}`);

    try {
        const response = await fetch(url, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });

        const fs = require('fs');
        // ... inside try block
        console.log(`Status: ${response.status} ${response.statusText}`);
        const text = await response.text();
        fs.writeFileSync('models_list.json', text);
        console.log('Saved to models_list.json');

    } catch (e) {
        console.error('Network Error:', e);
    }
}

listModels();
