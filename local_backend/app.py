from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import requests
from bs4 import BeautifulSoup
import json
import time
import os
from typing import List, Dict, Any
import uvicorn

app = FastAPI(
    title="My Modus Local Backend",
    description="Local Python backend for My Modus app",
    version="1.0.0"
)

# Enable CORS for all origins (adjust for production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

CACHE_FILE = "products_cache.json"
CACHE_TTL = 3600  # 1 hour

def load_cache():
    """Load cached products data"""
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r", encoding="utf-8") as f:
                cache = json.load(f)
                if time.time() - cache.get("timestamp", 0) < CACHE_TTL:
                    return cache.get("data", [])
        except Exception:
            pass
    return []

def save_cache(data):
    """Save products data to cache"""
    try:
        with open(CACHE_FILE, "w", encoding="utf-8") as f:
            json.dump({"timestamp": time.time(), "data": data}, f, ensure_ascii=False)
    except Exception as e:
        print(f"Error saving cache: {e}")

def scrape_wildberries_products():
    """Scrape My Modus products from Wildberries"""
    try:
        base_url = "https://www.wildberries.ru/brands/311036101-my-modus"
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
        
        response = requests.get(base_url, headers=headers, timeout=30)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, "html.parser")
        products = []
        
        # Find product cards
        product_cards = soup.select("article.product-card")
        
        for card in product_cards:
            try:
                # Extract product details
                link_tag = card.find("a", class_="product-card__main")
                if not link_tag:
                    continue
                    
                link = "https://www.wildberries.ru" + link_tag.get("href", "")
                title = link_tag.get("aria-label", "").strip()
                
                # Price
                price_tag = card.select_one(".price__lower-value")
                price = None
                if price_tag:
                    price_text = price_tag.text.replace("\u00a0", "").replace("₽", "")
                    try:
                        price = int(price_text)
                    except Value:
                        pass
                
                # Old price
                old_price_tag = card.select_one(".price__old-value")
                old_price = None
                if old_price_tag:
                    old_price_text = old_price_tag.text.replace("\u00a0", "").replace("₽", "")
                    try:
                        old_price = int(old_price_text)
                    except Value:
                        pass
                
                # Discount
                discount_tag = card.select_one(".price__discount")
                discount = None
                if discount_tag:
                    discount_text = discount_tag.text.replace("%", "").strip()
                    try:
                        discount = int(discount_text)
                    except Value:
                        pass
                
                # Image
                img_tag = card.find("img")
                image = img_tag.get("src") if img_tag else None
                
                if title:  # Only add if we have a title
                    products.append({
                        "title": title,
                        "price": price,
                        "oldPrice": old_price,
                        "discount": discount,
                        "image": image,
                        "link": link
                    })
                    
            except Exception as e:
                print(f"Error parsing product: {e}")
                continue
        
        return products
        
    except requests.RequestException as e:
        print(f"Error fetching products: {e}")
        return []
    except Exception as e:
        print(f"Unexpected error: {e}")
        return []

@app.get("/")
def read_root():
    """Root endpoint"""
    return {
        "message": "My Modus Local Backend is running",
        "endpoints": {
            "/products": "Get My Modus products",
            "/health": "Health check"
        }
    }

@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": time.time()}

@app.get("/products")
def get_products():
    """Get My Modus products with caching"""
    try:
        # Try cache first
        cached_products = load_cache()
        if cached_products:
            return {
                "source": "cache",
                "products": cached_products,
                "count": len(cached_products)
            }
        
        # Scrape fresh data
        products = scrape_wildberries_products()
        
        if products:
            save_cache(products)
            return {
                "source": "fresh",
                "products": products,
                "count": len(products)
            }
        else:
            return {
                "source": "empty",
                "products": [],
                "count": 0,
                "message": "No products found"
            }
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/products/refresh")
def refresh_products():
    """Force refresh products cache"""
    try:
        products = scrape_wildberries_products()
        save_cache(products)
        return {
            "source": "refreshed",
            "products": products,
            "count": len(products)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    print("Starting My Modus Local Backend...")
    print("Available at: http://localhost:8000")
    print("API Documentation: http://localhost:8000/docs")
    uvicorn.run(app, host="0.0.0.0", port=8000)
