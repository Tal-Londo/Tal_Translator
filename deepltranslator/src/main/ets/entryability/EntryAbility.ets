import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { configManager } from '../model/ConfigManager';

const DOMAIN = 0x0001;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext()
        .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'DeepLTranslator', 'Failed to set colorMode: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'DeepLTranslator', 'EntryAbility onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'DeepLTranslator', 'EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'DeepLTranslator', 'EntryAbility onWindowStageCreate');

    configManager.init(this.context);

    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'DeepLTranslator', 'Failed to load SplashPage: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'DeepLTranslator', 'Succeeded in loading SplashPage.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'DeepLTranslator', 'EntryAbility onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'DeepLTranslator', 'EntryAbility onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'DeepLTranslator', 'EntryAbility onBackground');
  }
}