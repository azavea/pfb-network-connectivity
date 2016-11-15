import { browser, element, by } from 'protractor';

export class PfbNetworkConnectivityPage {
  navigateTo() {
    return browser.get('/');
  }

  getParagraphText() {
    return element(by.css('pfb-root h1')).getText();
  }
}
