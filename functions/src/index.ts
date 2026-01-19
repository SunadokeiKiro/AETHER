import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { GoogleGenerativeAI } from '@google/generative-ai';
import * as dotenv from 'dotenv';

dotenv.config();
admin.initializeApp();

// Gemini API初期化
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');

// システムプロンプト
const systemPrompt = `你是AETHER应用助手。请用日语回答。

【 capabilities 】
- Timer/Stopwatch, Memo, Alarm, Theme, Navigation, Calculator, Weather

【 instructions 】
若用户请求操作，必须仅返回以下JSON格式。严禁包含Markdown标记或这是JSON的说明文字。

type Response = SingleAction | MultiAction;

interface SingleAction {
  action: ActionType;
  params: Params;
}

interface MultiAction {
  actions: SingleAction[];
}

type ActionType = 
  | "timer_control" // { type: "countdown"|"stopwatch", action: "start"|"pause"|"resume"|"stop"|"reset", duration: int (sec) }
  | "memo_control"  // { sub_action: "create"|"update"|"delete"|"search", title?: str, content?: str, query?: str }
  | "alarm_control" // { sub_action: "create"|"toggle"|"delete", time?: "HH:MM", label?: str }
  | "theme_change"  // { preset: "default"|"cyberpunk"|"minimal"|"nature"|"sunset" }
  | "navigate";     // { destination: "home"|"timer"|"memo"|"alarm"|"settings" }

对于普通对话，直接返回纯文本。`;

// Gemini Chat関数 (v2 API)
export const chat = onCall(async (request) => {
    const { message, conversationHistory } = request.data;

    if (!message || typeof message !== 'string') {
        throw new HttpsError('invalid-argument', 'メッセージが必要です');
    }

    try {
        const model = genAI.getGenerativeModel({
            model: 'gemini-2.0-flash',
            systemInstruction: systemPrompt,
        });

        // 会話履歴を構築
        const history = conversationHistory || [];
        const chatSession = model.startChat({ history });

        // メッセージを送信
        const result = await chatSession.sendMessage(message);
        const responseText = result.response.text();
        try {
            // Markdownコードブロックを除去（```json ... ``` or ``` ... ```）
            let cleanedResponse = responseText
                .replace(/^```json?\s*\n?/gmi, '')
                .replace(/\n?```\s*$/gmi, '')
                .trim();

            const jsonMatch = cleanedResponse.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                const parsed = JSON.parse(jsonMatch[0]);

                // 複数アクション ("actions" 配列) の場合
                if (parsed.actions && Array.isArray(parsed.actions)) {
                    return {
                        type: 'action',
                        actions: parsed.actions, // アクションのリスト
                        text: cleanedResponse.replace(jsonMatch[0], '').trim() || null,
                        fullText: responseText // 履歴用
                    };
                }

                // 単一アクションの場合
                if (parsed.action) {
                    const { action, params: nestedParams, ...flatParams } = parsed;
                    const finalParams = nestedParams || flatParams;

                    return {
                        type: 'action',
                        actions: [{ action, params: finalParams }], // リストに正規化
                        text: cleanedResponse.replace(jsonMatch[0], '').trim() || null,
                        fullText: responseText // 履歴用
                    };
                }
            }
        } catch (parseError) {
            // JSONパース失敗をログに記録（デバッグ用）
            console.warn('JSON parse failed, treating as text:', parseError, 'Response:', responseText.substring(0, 200));
        }

        // 通常のテキスト応答
        return {
            type: 'text',
            actions: [],
            text: responseText,
            fullText: responseText
        };
    } catch (error: any) {
        console.error('Gemini API Error Details:', {
            message: error.message,
            status: error.status,
            statusText: error.statusText,
            details: error.errorDetails,
            apiKeyPresent: !!process.env.GEMINI_API_KEY,
            apiKeyLength: process.env.GEMINI_API_KEY?.length
        });
        throw new HttpsError('internal', `AI処理中にエラーが発生しました: ${error.message}`);
    }
});

// ヘルスチェック用 (v2 API)
export const healthCheck = onRequest((req, res) => {
    res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});
