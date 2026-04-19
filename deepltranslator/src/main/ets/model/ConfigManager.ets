import preferences from '@ohos.data.preferences';
import { Context } from '@kit.AbilityKit';
import { AppStorageKeys, AppConfig } from './DataModel';

const DEFAULT_CONFIG: AppConfig = {
  apiKey: '',
  usePro: false
};

export class ConfigManager {
  private static instance: ConfigManager | null = null;
  private initialized: boolean = false;
  private pref: preferences.Preferences | null = null;
  private prefName: string = 'global_config';

  static getInstance(): ConfigManager {
    if (!ConfigManager.instance) {
      ConfigManager.instance = new ConfigManager();
    }
    return ConfigManager.instance;
  }

  async init(context: Context): Promise<void> {
    if (this.initialized) {
      return;
    }
    try {
      this.pref = await preferences.getPreferences(context, { name: this.prefName });
      this.initialized = true;
    } catch (e) {
      console.error('ConfigManager init failed:', JSON.stringify(e));
    }
  }

  getApiKey(): string {
    if (!this.pref) {
      return DEFAULT_CONFIG.apiKey;
    }
    try {
      const val = this.pref.getSync(AppStorageKeys.API_KEY, DEFAULT_CONFIG.apiKey);
      return val as string;
    } catch {
      return DEFAULT_CONFIG.apiKey;
    }
  }

  setApiKey(apiKey: string): void {
    if (!this.pref) {
      return;
    }
    try {
      this.pref.putSync(AppStorageKeys.API_KEY, apiKey);
      this.pref.flush();
    } catch (e) {
      console.error('ConfigManager setApiKey failed:', JSON.stringify(e));
    }
  }

  getUsePro(): boolean {
    if (!this.pref) {
      return DEFAULT_CONFIG.usePro;
    }
    try {
      const val = this.pref.getSync(AppStorageKeys.USE_PRO, DEFAULT_CONFIG.usePro);
      return val as boolean;
    } catch {
      return DEFAULT_CONFIG.usePro;
    }
  }

  setUsePro(usePro: boolean): void {
    if (!this.pref) {
      return;
    }
    try {
      this.pref.putSync(AppStorageKeys.USE_PRO, usePro);
      this.pref.flush();
    } catch (e) {
      console.error('ConfigManager setUsePro failed:', JSON.stringify(e));
    }
  }

  getConfig(): AppConfig {
    return {
      apiKey: this.getApiKey(),
      usePro: this.getUsePro()
    };
  }

  saveConfig(apiKey: string, usePro: boolean): void {
    this.setApiKey(apiKey);
    this.setUsePro(usePro);
  }

  isConfigured(): boolean {
    return this.getApiKey().length > 0;
  }
}

export const configManager = ConfigManager.getInstance();