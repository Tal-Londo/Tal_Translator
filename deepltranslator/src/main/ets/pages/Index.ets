import { ArcSwiper, ArcSwiperController, ArcDotIndicator, ArcDirection, ArcSwiperAttribute, ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute, LengthMetrics, ArcButton, ArcButtonOptions, ArcButtonPosition, ArcButtonStyleMode } from '@kit.ArkUI';
import { deepLService } from '../model/DeepLService';
import { historyStore } from '../model/HistoryStore';
import { configManager } from '../model/ConfigManager';
import { TranslateRecord, LANGUAGE_KEYS, TARGET_LANGUAGE_KEYS, SUPPORTED_LANGUAGES } from '../model/DataModel';
import { LanguageSelector, EmptyStateView, LoadingView } from '../components/CommonComponents';
import { ApiKeyInputPanel, ApiKeyStatusCard } from '../components/ApiKeyComponents';
import { generateRecordId } from '../utils/Utils';

const ITEM_SPACE: number = 6;

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State sourceText: string = '';
  @State targetText: string = '';
  @State sourceLang: string = 'AUTO';
  @State targetLang: string = 'ZH';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State historyList: TranslateRecord[] = [];
  @State settingsKey: string = '';
  @State settingsPro: boolean = false;
  @State settingsEdit: boolean = false;
  @State settingsInput: string = '';
  @State settingsError: string = '';
  @State settingsLoading: boolean = false;
  @State translateBtnScale: number = 1.0;
  @State showLanguageSelector: boolean = false;
  @State languageSelectType: string = '';
  @State previousTabIndex: number = 0;

  private arcSwiperController: ArcSwiperController = new ArcSwiperController();
  private translateScroller: Scroller = new Scroller();
  private storeInitialized: boolean = false;

  aboutToAppear(): void {
    this.initApp();
  }

  async initApp(): Promise<void> {
    await configManager.init(getContext(this));
    deepLService.setApiKey(configManager.getApiKey());
    deepLService.setUsePro(configManager.getUsePro());
    this.settingsKey = configManager.getApiKey();
    this.settingsPro = configManager.getUsePro();
    if (!this.storeInitialized) {
      await historyStore.init(getContext(this));
      this.storeInitialized = true;
    }
  }

  async doTranslate(): Promise<void> {
    if (!this.sourceText.trim()) {
      this.errorMessage = '请输入文本';
      return;
    }
    if (!deepLService.isConfigured()) {
      this.errorMessage = '请先在设置中配置 API Key';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const result = await deepLService.translate(
        this.sourceText.trim(),
        this.sourceLang,
        this.targetLang
      );
      this.targetText = result;

      const record: TranslateRecord = {
        id: generateRecordId(),
        sourceText: this.sourceText.trim(),
        targetText: result,
        sourceLang: this.sourceLang,
        targetLang: this.targetLang,
        timestamp: Date.now()
      };

      await historyStore.addRecord(record);
      this.historyList = await historyStore.getHistory();
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      this.errorMessage = msg;
    } finally {
      this.isLoading = false;
    }
  }

  async loadHistory(): Promise<void> {
    if (!this.storeInitialized) {
      await historyStore.init(getContext(this));
      this.storeInitialized = true;
    }
    this.historyList = await historyStore.getHistory();
  }

  async clearHistory(): Promise<void> {
    await historyStore.clearHistory();
    this.historyList = [];
  }

  swapLanguages(): void {
    if (this.sourceLang === 'AUTO') {
      return;
    }
    const temp = this.sourceLang;
    this.sourceLang = this.targetLang;
    this.targetLang = temp;
  }

  startEditSettings(): void {
    this.settingsEdit = true;
    this.settingsInput = this.settingsKey;
    this.settingsError = '';
  }

  cancelEditSettings(): void {
    this.settingsEdit = false;
  }

  async saveSettings(): Promise<void> {
    if (!this.settingsInput.trim()) {
      this.settingsError = 'Key 不能为空';
      return;
    }

    this.settingsError = '';
    this.settingsLoading = true;

    try {
      configManager.saveConfig(this.settingsInput.trim(), this.settingsPro);
      deepLService.setApiKey(configManager.getApiKey());
      deepLService.setUsePro(configManager.getUsePro());
      this.settingsKey = configManager.getApiKey();
      this.settingsPro = configManager.getUsePro();
      this.settingsEdit = false;
    } finally {
      this.settingsLoading = false;
    }
  }

  fillFromHistory(record: TranslateRecord): void {
    this.sourceText = record.sourceText;
    this.targetText = record.targetText;
    this.sourceLang = record.sourceLang;
    this.targetLang = record.targetLang;
    this.currentIndex = 0;
  }

  exitLanguageSelector(): void {
    this.showLanguageSelector = false;
  }

  @Builder
  translateTab() {
    ArcList() {
      ArcListItem() {
        Column() {
          Text('翻译')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 8, bottom: 8 })
        }
        .width('100%')
      }
      .width('100%')
      .height(48)
      .focusable(true)
      .focusOnTouch(true)

      ArcListItem() {
        Row() {
          Column() {
            Text('原文').fontSize(10).fontColor('#8E8E93')
            Text(SUPPORTED_LANGUAGES[this.sourceLang] || this.sourceLang).fontSize(14).fontColor('#FFFFFF')
          }
          .onClick(() => {
            this.languageSelectType = 'source';
            this.showLanguageSelector = true;
          })
          .layoutWeight(1)

          Text('⇄')
            .fontSize(14)
            .fontColor('#0A84FF')
            .margin({ left: 8, right: 8 })
            .onClick(() => this.swapLanguages())

          Column() {
            Text('译文').fontSize(10).fontColor('#8E8E93')
            Text(SUPPORTED_LANGUAGES[this.targetLang] || this.targetLang).fontSize(14).fontColor('#FFFFFF')
          }
          .onClick(() => {
            this.languageSelectType = 'target';
            this.showLanguageSelector = true;
          })
          .layoutWeight(1)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 12, right: 12 })
      }
      .width('80%')
      .height(48)
      .backgroundColor('#1C1C1E')
      .borderRadius(16)
      .alignSelf(ItemAlign.Center)
      .focusable(true)
      .focusOnTouch(true)

      ArcListItem() {
        TextArea({ text: this.sourceText, placeholder: '输入文字...' })
          .width('100%')
          .height('100%')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .caretColor('#0A84FF')
          .placeholderColor('#636366')
          .backgroundColor('#1C1C1E')
          .borderRadius(12)
          .padding(12)
          .onChange((text: string) => {
            this.sourceText = text;
          })
      }
      .width('80%')
      .height(120)
      .backgroundColor('#26FFFFFF')
      .borderRadius(16)
      .alignSelf(ItemAlign.Center)

      if (this.errorMessage) {
        ArcListItem() {
          Text(this.errorMessage).fontSize(10).fontColor('#FF453A').width('100%').textAlign(TextAlign.Center)
        }
        .width('80%')
        .height(32)
        .alignSelf(ItemAlign.Center)
      }

      ArcListItem() {
        Button('翻 译')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .height(36)
          .width('80%')
          .backgroundColor(this.isLoading ? '#3A3A3C' : '#0A84FF')
          .fontColor('#FFFFFF')
          .borderRadius(18)
          .alignSelf(ItemAlign.Center)
          .enabled(!this.isLoading)
          .scale({ x: this.translateBtnScale, y: this.translateBtnScale })
          .onFocus(() => {
            this.translateBtnScale = 1.1;
          })
          .onBlur(() => {
            this.translateBtnScale = 1.0;
          })
          .onClick(() => this.doTranslate())
      }
      .width('80%')
      .height(48)
      .alignSelf(ItemAlign.Center)
      .focusable(true)
      .focusOnTouch(true)

      ArcListItem() {
        Scroll() {
          if (this.isLoading) {
            LoadingView({ message: '翻译中...' })
          } else {
            Text(this.targetText || '译文将在此显示')
              .fontSize(14)
              .fontColor(this.targetText ? '#FFFFFF' : '#636366')
              .width('100%')
              .textAlign(TextAlign.Start)
              .padding(12)
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('80%')
      .height(120)
      .backgroundColor('#1C1C1E')
      .borderRadius(16)
      .alignSelf(ItemAlign.Center)
      .focusable(true)
      .focusOnTouch(true)
    }
    .id('translateTab')
    .space(LengthMetrics.vp(ITEM_SPACE))
    .scrollBar(BarState.Off)
    .fadingEdge(true)
    .focusable(true)
    .focusOnTouch(true)
    .defaultFocus(true)
    .enableScrollInteraction(true)
    .digitalCrownSensitivity(1.0)
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  @Builder
  historyTab() {
    Column() {
      Text('历史')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 8, bottom: 8 })

      if (this.historyList.length > 0) {
        Text('清空')
          .fontSize(11)
          .fontColor('#FF453A')
          .width('100%')
          .textAlign(TextAlign.Center)
          .onClick(() => this.clearHistory())
      }

      if (this.historyList.length === 0) {
        EmptyStateView({
          emoji: '📭',
          title: '暂无翻译记录',
          subtitle: '返回翻译页面开始使用'
        })
      } else {
        ArcList() {
          ForEach(this.historyList, (record: TranslateRecord) => {
            ArcListItem() {
              this.historyItemBuilder(record)
            }
            .width('80%')
            .height(100)
            .backgroundColor('#26FFFFFF')
            .borderRadius(16)
          }, (record: TranslateRecord) => String(record.id))
        }
        .id('historyList')
        .space(LengthMetrics.vp(ITEM_SPACE))
        .scrollBar(BarState.Off)
        .fadingEdge(true)
        .enableScrollInteraction(true)
        .focusable(true)
        .focusOnTouch(true)
        .defaultFocus(true)
        .digitalCrownSensitivity(1.0)
        .width('100%')
        .layoutWeight(1)
      }
    }
    .id('historyTab')
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .focusable(true)
    .focusOnTouch(true)
  }

  @Builder
  historyItemBuilder(record: TranslateRecord) {
    Row() {
      Column({ space: 3 }) {
        Row() {
          Text(SUPPORTED_LANGUAGES[record.sourceLang] || record.sourceLang)
            .fontSize(9).fontColor('#0A84FF')
          Text(' → ').fontSize(9).fontColor('#636366')
          Text(SUPPORTED_LANGUAGES[record.targetLang] || record.targetLang)
            .fontSize(9).fontColor('#0A84FF')
        }
        Text(record.sourceText)
          .fontSize(12).fontColor('#FFFFFF')
          .width('100%').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(record.targetText)
          .fontSize(11).fontColor('#AAAAAA')
          .width('100%').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.formatTime(record.timestamp))
        .fontSize(9).fontColor('#636366').alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding(10)
    .onClick(() => this.fillFromHistory(record))
  }

  @Builder
  settingsTab() {
    Column() {
      Text('设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 8, bottom: 8 })

      if (this.settingsEdit) {
        ApiKeyInputPanel({
          isEditing: $settingsEdit,
          inputKey: $settingsInput,
          errorMessage: $settingsError,
          isLoading: $settingsLoading,
          onSave: () => this.saveSettings(),
          onCancel: () => this.cancelEditSettings()
        })
      }

      ArcList() {
        ArcListItem() {
          ApiKeyStatusCard({
            apiKey: this.settingsKey,
            usePro: this.settingsPro,
            onEditClick: () => this.startEditSettings()
          })
        }
        .width('80%')
        .alignSelf(ItemAlign.Center)

        ArcListItem() {
          Column() {
            this.infoRow('Tal·译', 'v1.0.1 · Tal-Londo@TKStudio')
            Divider().color('#2C2C2E').margin({ left: 12 })
            this.infoRow('隐私说明', '翻译内容直接发送至 DeepL 服务器')
            Divider().color('#2C2C2E').margin({ left: 12 })
            this.infoRow('获取 API Key', '前往 dev.deepl.com 免费注册')
          }
          .width('100%')
          .backgroundColor('#1C1C1E')
          .borderRadius(12)
        }
        .width('80%')
        .alignSelf(ItemAlign.Center)
      }
      .space(LengthMetrics.vp(ITEM_SPACE))
      .scrollBar(BarState.Off)
      .fadingEdge(true)
      .enableScrollInteraction(true)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .digitalCrownSensitivity(1.0)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  @Builder
  infoRow(title: string, content: string) {
    Column() {
      Text(title).fontSize(12).fontColor('#FFFFFF')
      Text(content).fontSize(10).fontColor('#8E8E93').margin({ top: 2 })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  languageSelectorDialog() {
    RelativeContainer() {
      ArcList({
        initialIndex: this.languageSelectType === 'source' 
          ? LANGUAGE_KEYS.indexOf(this.sourceLang) 
          : TARGET_LANGUAGE_KEYS.filter(k => k !== 'AUTO').indexOf(this.targetLang)
      }) {
        ForEach(this.languageSelectType === 'source' ? LANGUAGE_KEYS : TARGET_LANGUAGE_KEYS.filter(k => k !== 'AUTO'), (key: string) => {
          ArcListItem() {
            Text(SUPPORTED_LANGUAGES[key] || key)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .width('100%')
              .textAlign(TextAlign.Center)
              .onClick(() => {
                if (this.languageSelectType === 'source') {
                  this.sourceLang = key;
                } else {
                  this.targetLang = key;
                }
                this.exitLanguageSelector();
              })
          }
          .height(32)
          .width('80%')
          .backgroundColor((this.languageSelectType === 'source' && this.sourceLang === key) ||
                          (this.languageSelectType === 'target' && this.targetLang === key) 
                          ? '#0A84FF' : '#26FFFFFF')
          .borderRadius(16)
          .alignSelf(ItemAlign.Center)
        }, (key: string) => key)
      }
      .id('languageList')
      .space(LengthMetrics.vp(ITEM_SPACE))
      .scrollBar(BarState.Off)
      .fadingEdge(true)
      .enableScrollInteraction(true)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
      .digitalCrownSensitivity(1.0)
      .width('100%')
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .margin({ top: 8 })

      ArcButton({
        options: new ArcButtonOptions({
          label: '返回',
          styleMode: ArcButtonStyleMode.EMPHASIZED_LIGHT,
          onClick: () => this.exitLanguageSelector()
        })
      })
      .alignRules({
        middle: { anchor: '__container__', align: HorizontalAlign.Center },
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .padding({ left: 12, right: 12, bottom: 8 })
    .onKeyEvent((event?: KeyEvent) => {
      if (event && event.keyCode === 2055 && event.type === KeyType.Down) {
        this.exitLanguageSelector();
        return true;
      }
      return false;
    })
    .onAppear(() => {
      this.previousTabIndex = this.currentIndex;
      setTimeout(() => {
        this.getUIContext().getFocusController().requestFocus('languageList');
      }, 100);
    })
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${month}/${day} ${hours}:${minutes}`;
  }

  build() {
    Stack() {
      Column() {
        ArcSwiper(this.arcSwiperController) {
          this.translateTab()
          this.historyTab()
          this.settingsTab()
        }
        .index(this.currentIndex)
        .indicator(new ArcDotIndicator()
          .arcDirection(ArcDirection.SIX_CLOCK_DIRECTION)
          .itemColor('#40FFFFFF')
          .selectedItemColor('#FFFFFF')
          .backgroundColor('#20000000')
        )
        .onChange((idx: number) => {
          this.currentIndex = idx;
          if (idx === 1) {
            this.loadHistory();
            setTimeout(() => {
              if (this.historyList.length > 0) {
                this.getUIContext().getFocusController().requestFocus('historyList');
              } else {
                this.getUIContext().getFocusController().requestFocus('historyTab');
              }
            }, 200);
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')

      if (this.showLanguageSelector) {
        this.languageSelectorDialog()
      }
    }
    .width('100%')
    .height('100%')
  }
}