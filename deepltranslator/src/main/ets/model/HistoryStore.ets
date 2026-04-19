import preferences from '@ohos.data.preferences';
import { Context } from '@kit.AbilityKit';
import { TranslateRecord, MAX_HISTORY_SIZE, AppStorageKeys } from './DataModel';

export class HistoryStore {
  private pref: preferences.Preferences | null = null;
  private prefName: string = 'translator_prefs';

  async init(context: Context): Promise<void> {
    if (this.pref) {
      return;
    }
    try {
      this.pref = await preferences.getPreferences(context, { name: this.prefName });
    } catch (e) {
      console.error('HistoryStore init failed:', JSON.stringify(e));
    }
  }

  async getHistory(): Promise<TranslateRecord[]> {
    if (!this.pref) {
      return [];
    }
    try {
      const val = await this.pref.get(AppStorageKeys.HISTORY, '[]');
      return JSON.parse(val as string) as TranslateRecord[];
    } catch {
      return [];
    }
  }

  async addRecord(record: TranslateRecord): Promise<void> {
    if (!this.pref) {
      return;
    }
    try {
      const list = await this.getHistory();
      list.unshift(record);
      if (list.length > MAX_HISTORY_SIZE) {
        list.splice(MAX_HISTORY_SIZE);
      }
      await this.pref.put(AppStorageKeys.HISTORY, JSON.stringify(list));
      await this.pref.flush();
    } catch (e) {
      console.error('HistoryStore addRecord failed:', JSON.stringify(e));
    }
  }

  async deleteRecord(id: number): Promise<void> {
    if (!this.pref) {
      return;
    }
    try {
      const list = await this.getHistory();
      const filteredList = list.filter(item => item.id !== id);
      await this.pref.put(AppStorageKeys.HISTORY, JSON.stringify(filteredList));
      await this.pref.flush();
    } catch (e) {
      console.error('HistoryStore deleteRecord failed:', JSON.stringify(e));
    }
  }

  async clearHistory(): Promise<void> {
    if (!this.pref) {
      return;
    }
    try {
      await this.pref.put(AppStorageKeys.HISTORY, '[]');
      await this.pref.flush();
    } catch (e) {
      console.error('HistoryStore clearHistory failed:', JSON.stringify(e));
    }
  }
}

export const historyStore = new HistoryStore();