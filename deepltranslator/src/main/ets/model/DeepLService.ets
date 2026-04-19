import http from '@ohos.net.http';
import { DeepLResponse } from './DataModel';

const DEEPL_FREE_URL = 'https://api-free.deepl.com/v2/translate';
const DEEPL_PRO_URL = 'https://api.deepl.com/v2/translate';

export class DeepLService {
  private apiKey: string = '';
  private usePro: boolean = false;

  setApiKey(apiKey: string): void {
    this.apiKey = apiKey;
  }

  getApiKey(): string {
    return this.apiKey;
  }

  setUsePro(usePro: boolean): void {
    this.usePro = usePro;
  }

  isUsePro(): boolean {
    return this.usePro;
  }

  isConfigured(): boolean {
    return this.apiKey.length > 0;
  }

  getApiUrl(): string {
    return this.usePro ? DEEPL_PRO_URL : DEEPL_FREE_URL;
  }

  async translate(text: string, sourceLang: string, targetLang: string): Promise<string> {
    if (!this.apiKey) {
      throw new Error('请先在设置中配置 DeepL API Key');
    }

    if (!text.trim()) {
      throw new Error('请输入要翻译的文本');
    }

    const url: string = this.getApiUrl();
    const encodedText: string = encodeURIComponent(text);
    const encodedTarget: string = encodeURIComponent(targetLang);
    let formBody: string = `text=${encodedText}&target_lang=${encodedTarget}`;

    if (sourceLang !== 'AUTO') {
      const encodedSource: string = encodeURIComponent(sourceLang);
      formBody = `${formBody}&source_lang=${encodedSource}`;
    }

    const authHeader: string = `DeepL-Auth-Key ${this.apiKey}`;

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Authorization': authHeader,
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        extraData: formBody,
        expectDataType: http.HttpDataType.STRING
      });

      if (response.responseCode !== 200) {
        const errMsg = this.parseError(response.result as string);
        throw new Error(`翻译失败 (${response.responseCode}): ${errMsg}`);
      }

      const data: DeepLResponse = JSON.parse(response.result as string);
      if (data && data.translations && data.translations.length > 0) {
        return data.translations[0].text;
      }
      throw new Error('翻译结果解析失败');
    } finally {
      httpRequest.destroy();
    }
  }

  private parseError(responseBody: string): string {
    try {
      const obj: Record<string, Object> = JSON.parse(responseBody);
      if (obj['message'] && typeof obj['message'] === 'string') {
        return obj['message'] as string;
      }
      const errorObj = obj['error'];
      if (errorObj && typeof errorObj === 'object') {
        const errRecord = errorObj as Record<string, Object>;
        if (errRecord['message'] && typeof errRecord['message'] === 'string') {
          return errRecord['message'] as string;
        }
      }
    } catch {
    }
    return '未知错误，请检查网络和 API Key';
  }
}

export const deepLService = new DeepLService();