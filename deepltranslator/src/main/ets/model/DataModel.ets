export const SUPPORTED_LANGUAGES: Record<string, string> = {
  'AUTO': '自动检测',
  'ZH': '中文',
  'EN': '英语',
  'JA': '日语',
  'KO': '韩语',
  'FR': '法语',
  'DE': '德语',
  'ES': '西班牙语',
  'PT': '葡萄牙语',
  'IT': '意大利语',
  'RU': '俄语',
  'PL': '波兰语',
  'NL': '荷兰语',
  'TR': '土耳其语',
  'UK': '乌克兰语'
};

export const TARGET_LANGUAGES: Record<string, string> = {
  'ZH': '中文',
  'EN': '英语',
  'JA': '日语',
  'KO': '韩语',
  'FR': '法语',
  'DE': '德语',
  'ES': '西班牙语',
  'PT': '葡萄牙语',
  'IT': '意大利语',
  'RU': '俄语',
  'PL': '波兰语',
  'NL': '荷兰语',
  'TR': '土耳其语',
  'UK': '乌克兰语'
};

export const LANGUAGE_KEYS: string[] = ['AUTO', 'ZH', 'EN', 'JA', 'KO', 'FR', 'DE', 'ES', 'PT', 'IT', 'RU', 'PL', 'NL', 'TR', 'UK'];
export const TARGET_LANGUAGE_KEYS: string[] = ['ZH', 'EN', 'JA', 'KO', 'FR', 'DE', 'ES', 'PT', 'IT', 'RU', 'PL', 'NL', 'TR', 'UK'];

export interface DeepLResponse {
  translations: DeepLTranslation[];
}

export interface DeepLTranslation {
  detected_source_language?: string;
  text: string;
}

export interface TranslateRecord {
  id: number;
  sourceText: string;
  targetText: string;
  sourceLang: string;
  targetLang: string;
  timestamp: number;
}

export interface AppConfig {
  apiKey: string;
  usePro: boolean;
}

export class AppStorageKeys {
  static readonly API_KEY: string = 'app_api_key';
  static readonly USE_PRO: string = 'app_use_pro';
  static readonly HISTORY: string = 'app_translate_history';
}

export const MAX_HISTORY_SIZE = 100;