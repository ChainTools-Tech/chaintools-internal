

import os
from notion.client import NotionClient
from telegram import Bot
from telegram.ext import Updater, CommandHandler

# Set your Notion API token
NOTION_API_TOKEN = 'secret_6dQOViITtEJjkY3yZczBLdyKZGDkWVZZ6LJ67IMfgzK'
# Set your Notion database URL
NOTION_DATABASE_URL = 'https://www.notion.so/e7cf4a23bef44cbab3299f6cf458b7f7?v=671615299307469fbd7b7261ce97f99d'
# Set your Telegram bot token
TELEGRAM_BOT_TOKEN = '5919143356:AAEm0No_Eo-J5C-Q768sFxF0QR3f07XMXPQ'
# Set your Telegram chat ID (group chat ID)
TELEGRAM_CHAT_ID = '1376500711'

def get_new_tasks_from_notion():
    # Authenticate with Notion using the provided API token
    notion_client = NotionClient(token_v2=NOTION_API_TOKEN)
    
    # Access the Notion database
    notion_database = notion_client.get_collection_view(NOTION_DATABASE_URL)

    # Get all tasks from the database
    tasks = notion_database.collection.get_rows()

    # Assuming each row represents a task and has a 'Name' property
    return [task.Name for task in tasks]

def send_alert_to_telegram(new_tasks):
    # Initialize the Telegram bot
    bot = Bot(token=TELEGRAM_BOT_TOKEN)

    # Send a message to the Telegram chat with the new tasks
    message = "New tasks in Notion:\n" + "\n".join(new_tasks)
    bot.send_message(chat_id=TELEGRAM_CHAT_ID, text=message)

def check_for_new_tasks_and_alert(context):
    # Get the current tasks from Notion
    current_tasks = get_new_tasks_from_notion()

    # Check if there are any new tasks compared to the previous run
    if hasattr(context, 'previous_tasks'):
        new_tasks = [task for task in current_tasks if task not in context.previous_tasks]
        if new_tasks:
            # Send an alert with the new tasks to Telegram
            send_alert_to_telegram(new_tasks)

    # Update the context with the current tasks for the next run
    context.previous_tasks = current_tasks

def main():
    # Initialize the Telegram bot updater
    updater = Updater(token=TELEGRAM_BOT_TOKEN, use_context=True)

    # Set up a job to run every 5 minutes (adjust the interval as needed)
    job_queue = updater.job_queue
    job_queue.run_repeating(check_for_new_tasks_and_alert, interval=300, first=0)

    # Start the bot
    updater.start_polling()
    updater.idle()

if __name__ == "__main__":
    main()
