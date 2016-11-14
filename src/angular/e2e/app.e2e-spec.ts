import { PfbNetworkConnectivityPage } from './app.po';

describe('pfb-network-connectivity App', function() {
  let page: PfbNetworkConnectivityPage;

  beforeEach(() => {
    page = new PfbNetworkConnectivityPage();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('pfb works!');
  });
});
