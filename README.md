# Modern Warfare & Warzone Calling Cards
_Last updated: 2021-02-12_
_Total #: 1846 calling cards_

This is a collection of calling cards from Call of Duty: Modern Warfare (2019) and Call of Duty: Warzone. 

All calling cards were scraped from [https://cod.tracker.gg/modern-warfare/db/loot?c=5](https://cod.tracker.gg/modern-warfare/db/loot?c=5).

While scraping the calling cards, I noticed that there were a few problems with the media. First, some calling cards that were just images were appearing as gifs. When I looked closer, the the image had been split into four quadrants, and the resulting images were appended together to appear as a gif. I took each frame of the gif and saved it as an image, and then I combined the four images back into their resulting calling card.

A similar issue appeared for animated calling cards. Each frame in the correct gif had been split into four quadrants and appended into a new gif. (So a 5-frame gif was appearing as a 20-frame gif). It was a mess. Again, I took out each frame, combined them into their proper images, and saved back into a new gif.

Sometimes the ordering of the frames was incorrect (for example, instead of frames 1, 2, 3, and 4 being from the first image, it was actually frames 1, 2, 7, and 8). I had to determine this manually and adjust my script. Likewise, other gif frames weren't split into multiple images, and so my script incorrectly combined those images together. I fixed those manually as well.

Unfortunately, I have no idea if there are missing calling cards. In addition, some of the calling cards are incorrect or don't have enough data; that is an issue with the CoD Tracker Database and there's nothing I can do.

I will periodically run a script to check for any new calling cards that have been added. This is not automatic.
