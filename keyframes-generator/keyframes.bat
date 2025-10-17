@echo off
echo Making SCXvid keyframes...
set video="%~1"
set video2="%~n1"
ffmpeg -i %video% -f yuv4mpegpipe -vf scale=640:360 -pix_fmt yuv420p -vsync drop - | SCXvid.exe %video2%_keyframes.log
echo Keyframes complete
@pause