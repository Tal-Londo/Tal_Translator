import { LengthMetrics } from '@kit.ArkUI';
import { TranslateRecord, SUPPORTED_LANGUAGES } from '../model/DataModel';
import { formatTimestamp } from '../utils/Utils';

interface SelectOption {
  value: string;
}

@Component
export struct LanguageSelector {
  @Prop label: string;
  @Prop selectedKey: string;
  @Prop languageKeys: string[];
  @Prop showAuto: boolean = true;
  @Prop hideLabel: boolean = false;
  onSelect: (key: string) => void = () => {};

  private getOptions(): SelectOption[] {
    const keys = this.showAuto ? this.languageKeys : this.languageKeys.filter(k => k !== 'AUTO');
    return keys.map((k: string): SelectOption => ({ value: SUPPORTED_LANGUAGES[k] || k }));
  }

  private getSelectedIndex(): number {
    const keys = this.showAuto ? this.languageKeys : this.languageKeys.filter(k => k !== 'AUTO');
    return keys.indexOf(this.selectedKey);
  }

  build() {
    Row() {
      if (!this.hideLabel) {
        Text(this.label).fontSize(10).fontColor('#8E8E93').width(32)
      }
      Select(this.getOptions())
        .selected(this.getSelectedIndex())
        .height(30)
        .layoutWeight(1)
        .fontColor('#FFFFFF')
        .backgroundColor('#1C1C1E')
        .borderRadius(8)
        .onSelect((idx: number) => {
          const keys = this.showAuto ? this.languageKeys : this.languageKeys.filter(k => k !== 'AUTO');
          if (idx >= 0 && idx < keys.length) {
            this.onSelect(keys[idx]);
          }
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ left: this.hideLabel ? 0 : 12, right: this.hideLabel ? 0 : 12, top: 4, bottom: 4 })
  }
}

@Component
export struct HistoryListItem {
  @ObjectLink record: TranslateRecord;
  onItemClick: (record: TranslateRecord) => void = () => {};

  build() {
    Row() {
      Column({ space: 3 }) {
        Row() {
          Text(SUPPORTED_LANGUAGES[this.record.sourceLang] || this.record.sourceLang)
            .fontSize(9)
            .fontColor('#0A84FF')
          Text(' → ').fontSize(9).fontColor('#636366')
          Text(SUPPORTED_LANGUAGES[this.record.targetLang] || this.record.targetLang)
            .fontSize(9)
            .fontColor('#0A84FF')
        }
        Text(this.record.sourceText)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.record.targetText)
          .fontSize(11)
          .fontColor('#AAAAAA')
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(formatTimestamp(this.record.timestamp))
        .fontSize(9)
        .fontColor('#636366')
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding(10)
  }
}

@Component
export struct EmptyStateView {
  @Prop emoji: string = '📭';
  @Prop title: string;
  @Prop subtitle: string = '';

  build() {
    Column() {
      Text(this.emoji).fontSize(36)
      Text(this.title).fontSize(12).fontColor('#8E8E93').margin({ top: 6 })
      if (this.subtitle) {
        Text(this.subtitle).fontSize(11).fontColor('#636366').margin({ top: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Component
export struct LoadingView {
  @Prop message: string = '加载中...';

  build() {
    Row() {
      LoadingProgress().width(18).height(18).color('#0A84FF')
      Text(this.message).fontSize(12).fontColor('#8E8E93').margin({ left: 4 })
    }
    .width('100%')
    .padding({ left: 12, top: 4 })
  }
}
