#!/usr/bin/env python3
"""
My Modus Local Backend Startup Script
Run this script to start the local backend server
"""

import os
import sys
import subprocess
import webbrowser
import time

def check_python_version():
    """Check if Python 3.7+ is available"""
    if sys.version_info < (3, 7):
        print("❌ Python 3.7 or higher is required")
        return False
    return True

def install_requirements():
    """Install required packages"""
    print("📦 Installing requirements...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Requirements installed successfully")
        return True
    except subprocess.CalledProcessError:
        print("❌ Failed to install requirements")
        return False

def start_server():
    """Start the FastAPI server"""
    print("🚀 Starting My Modus Local Backend...")
    print("📍 Server will be available at: http://localhost:8000")
    print("📖 API Documentation: http://localhost:8000/docs")
    print("🔍 Health Check: http://localhost:8000/health")
    print("\nPress Ctrl+C to stop the server\n")
    
    try:
        # Open browser after a short delay
        time.sleep(2)
        webbrowser.open("http://localhost:8000/docs")
    except:
        pass
    
    try:
        subprocess.run([
            sys.executable, "-m", "uvicorn", 
            "app:app", 
            "--host", "0.0.0.0", 
            "--port", "8000",
            "--reload"
        ])
    except KeyboardInterrupt:
        print("\n\n👋 Server stopped by user")
    except Exception as e:
        print(f"❌ Error starting server: {e}")

def main():
    """Main startup function"""
    print("🎯 My Modus Local Backend Setup")
    print("=" * 40)
    
    if not check_python_version():
        return
    
    # Check if requirements are already installed
    try:
        import fastapi
        import uvicorn
        import requests
        import bs4
        print("✅ All requirements already installed")
    except ImportError:
        if not install_requirements():
            return
    
    start_server()

if __name__ == "__main__":
    main()
