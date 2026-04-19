import { configManager } from '../model/ConfigManager';
import { maskApiKey } from '../utils/Utils';

@Component
export struct ApiKeyInputPanel {
  @Link isEditing: boolean;
  @Link inputKey: string;
  @Link errorMessage: string;
  @Link isLoading: boolean;

  onSave: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column() {
      Text('配置 API Key')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ top: 10, bottom: 8 })

      TextInput({ placeholder: 'DeepL Auth Key', text: this.inputKey })
        .width('85%')
        .height(32)
        .fontSize(12)
        .fontColor('#FFFFFF')
        .caretColor('#0A84FF')
        .backgroundColor('#2C2C2E')
        .borderRadius(10)
        .margin({ bottom: 6 })
        .onChange((val: string) => {
          this.inputKey = val;
        })

      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(10)
          .fontColor('#FF453A')
          .width('85%')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 2 })
      }

      Row() {
        Button('取消')
          .fontSize(12)
          .width('40%')
          .height(30)
          .backgroundColor('#2C2C2E')
          .fontColor('#FFFFFF')
          .borderRadius(15)
          .onClick(() => {
            this.onCancel();
          })
        Button('保存')
          .fontSize(12)
          .width('40%')
          .height(30)
          .backgroundColor('#0A84FF')
          .fontColor('#FFFFFF')
          .borderRadius(15)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.onSave();
          })
      }
      .width('85%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 8 })
    }
    .width('100%')
    .backgroundColor('#1C1C1E')
    .borderRadius(12)
  }
}

@Component
export struct ApiKeyStatusCard {
  @Prop apiKey: string;
  @Prop usePro: boolean;
  onEditClick: () => void = () => {};

  build() {
    Column() {
      Row() {
        Column() {
          Text('DeepL API Key').fontSize(13).fontColor('#FFFFFF')
          if (this.apiKey) {
            Text('已配置 · ' + maskApiKey(this.apiKey))
              .fontSize(10)
              .fontColor('#34C759')
              .margin({ top: 2 })
          } else {
            Text('未配置 - 请先设置')
              .fontSize(10)
              .fontColor('#FF9500')
              .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.apiKey ? '设置' : '配置')
          .fontSize(12)
          .fontColor('#0A84FF')
          .onClick(() => {
            this.onEditClick();
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })

      Divider().color('#2C2C2E').margin({ left: 12 })

      Row() {
        Column() {
          Text('DeepL Pro 账号').fontSize(13).fontColor('#FFFFFF')
          Text('请确保您的API不是Free层级')
            .fontSize(10)
            .fontColor('#8E8E93')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.usePro })
          .selectedColor('#0A84FF')
          .onChange((val: boolean) => {
            configManager.setUsePro(val);
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    }
    .width('100%')
    .backgroundColor('#1C1C1E')
    .borderRadius(12)
  }
}
