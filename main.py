from playwright.sync_api import sync_playwright
from pyvirtualdisplay import Display
from time import sleep
import logging
FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
logging.basicConfig(level=logging.DEBUG, format=FORMAT)

with sync_playwright() as p:
    display = Display(visible=False, size=(800, 602))
    display.start()
    sleep(5)
    browser = p.chromium.launch(headless=False)
    page = browser.new_page()
    page.goto("http://playwright.dev")
    print(page.title())
    browser.close()
    display.stop()