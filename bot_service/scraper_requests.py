import httpx, re
from bs4 import BeautifulSoup
from urllib.parse import urlparse

USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0 Safari/537.36',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0 Safari/537.36',
    'MyModusBot/1.0 (+https://example.com)'
]

DEFAULT_TIMEOUT = 15.0
HEADERS = {'Accept-Language': 'en-US,en;q=0.9'}

def pick_ua():
    import time
    return USER_AGENTS[int(time.time()) % len(USER_AGENTS)]

def parse_price(text):
    if not text: return ''
    m = re.search(r'\d[\d\s,\.]*', text)
    return m.group(0).strip() if m else text.strip()

def scrape_via_requests(url, connector='generic'):
    # polite request
    headers = HEADERS.copy()
    headers['User-Agent'] = pick_ua()
    resp = httpx.get(url, timeout=DEFAULT_TIMEOUT, headers=headers)
    if resp.status_code != 200:
        raise Exception('HTTP ' + str(resp.status_code))
    soup = BeautifulSoup(resp.text, 'html.parser')
    # selectors heuristics depending on connector
    title = ''
    image = ''
    price = ''
    if connector == 'wildberries' or 'wildberries' in url:
        title = soup.select_one('meta[property="og:title"]') or soup.select_one('h1')
        image = soup.select_one('meta[property="og:image"]') or soup.select_one('.j-card-img')
        price_el = soup.select_one('.price') or soup.select_one('[class*=price]')
    elif connector == 'ozon' or 'ozon' in url:
        title = soup.select_one('meta[property="og:title"]') or soup.select_one('h1')
        image = soup.select_one('meta[property="og:image"]') or soup.select_one('.j-product-image')
        price_el = soup.select_one('.price') or soup.select_one('[class*=price]')
    else:
        title = soup.select_one('meta[property="og:title"]') or soup.select_one('h1') or soup.select_one('title')
        image = soup.select_one('meta[property="og:image"]') or soup.select_one('img')
        price_el = soup.select_one('[class*=price]') or soup.find(text=re.compile(r'\d[\d\s,\.]*'))
    t = title.attrs.get('content') if getattr(title, 'attrs', None) else (title.text.strip() if title else '')
    img = image.attrs.get('content') if getattr(image, 'attrs', None) else (image.attrs.get('src') if image and image.attrs else '') if image else ''
    p = ''
    if price_el:
        p = price_el.attrs.get('content') if getattr(price_el, 'attrs', None) else price_el.text.strip()
    p = parse_price(p)
    return {
        'title': t,
        'image': img,
        'price': p,
        'source_url': url
    }
