# Optional Playwright scraper - requires `playwright install` and browsers
from playwright.async_api import async_playwright
import asyncio

async def scrape_with_playwright(url):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()
        await page.goto(url, timeout=30000)
        # wait some common selectors
        await page.wait_for_timeout(1000)
        title = await page.query_selector('meta[property="og:title"]') or await page.query_selector('h1') or await page.title()
        image = await page.query_selector('meta[property="og:image"]') or await page.query_selector('img')
        price = await page.query_selector('[class*=price]') or None
        t = ''
        if hasattr(title, 'get_attribute'):
            t = await title.get_attribute('content') or await title.inner_text()
        else:
            t = title or ''
        img = await image.get_attribute('content') if image else ''
        p = await price.inner_text() if price else ''
        await browser.close()
        return {'title': t, 'image': img, 'price': p, 'source_url': url}

if __name__ == '__main__':
    import sys, asyncio
    url = sys.argv[1]
    print(asyncio.get_event_loop().run_until_complete(scrape_with_playwright(url)))
