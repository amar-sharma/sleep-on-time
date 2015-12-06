# sleep-on-time
Script that locks your computer so that you sleep on time.

After cloning this repository configure the script as follows:

`EMAIL_TO`: The random passwords are sent to this mail.

`MAIL_GUN`: If you want to use mail gun for email make it `1`, default is `0`

Change `default_password` to your default password

Change the @mailgun settings

Now in terminal type: `crontab -e`

Enter the following settings:

```
MAILTO="your Email-id"
*/5 2,3 * * * /path/to/sleep-on-time/change_pass.sh random
*/10 5-11,13 * * * /path/to/sleep-on-time/change_pass.sh default
* 2,3 * * * open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app || true
45,50,55 1 * * * open /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app || true
```
