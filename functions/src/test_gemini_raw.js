require('dotenv').config();

async function testGeminiRest() {
    const key = process.env.GEMINI_API_KEY;
    console.log(`Checking key: ${key ? 'Present' : 'Missing'}, Length: ${key?.length}`);

    const model = 'gemini-2.0-flash';
    // Using v1beta API
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`;

    console.log(`Target URL: ${url.replace(key, '***')}`);

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                contents: [{ parts: [{ text: "Hello" }] }]
            })
        });

        console.log(`Status: ${response.status} ${response.statusText}`);
        const text = await response.text();
        console.log('Response Body:', text);

    } catch (e) {
        console.error('Network Error:', e);
    }
}

testGeminiRest();
