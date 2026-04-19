import { router } from '@kit.ArkUI';

const ANIMATION_DELAY = 300;
const ANIMATION_DURATION = 500;

@Entry
@Component
struct SplashPage {
  @State fadeVal: number = 0;

  aboutToAppear(): void {
    this.getUIContext().animateTo({
      delay: ANIMATION_DELAY,
      duration: ANIMATION_DURATION,
      curve: Curve.EaseIn,
    }, () => {
      this.fadeVal = 1;
    });

    setTimeout(() => {
      router.replaceUrl({ url: 'pages/Index' });
    }, ANIMATION_DELAY + ANIMATION_DURATION + 200);
  }

  build() {
    Column() {
      Text('').fontSize(48)
      Text('Tal·Translator')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ top: 10 })
      Text('Tal Londo')
        .fontSize(14)
        .fontColor('#AAAAAA')
        .margin({ top: 6 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .justifyContent(FlexAlign.Center)
    .opacity(this.fadeVal)
  }
}
