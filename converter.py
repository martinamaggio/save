import sys
from converter import Converter
conv = Converter()

def convert_to_mp4(video, folder_src):
    # get information about the video file (optional)
    # info = conv.probe(foldersrc + video)

    video_name = video.split(".")[0] 

    video = folder_src + video
    new_video = folder_src + video_name + ".mp4"

    conv.convert(video, new_video, {
        'format': 'mp4',
        'audio': {
            'codec': 'aac',
            'samplerate': 11025,
            'channels': 2,
        },
        'video': {
            'codec': 'hevc',
            'width': 720,
            'height': 400,
            'fps': 25
        }})


def main(args):
    video = args[1]
    folder_src = args[2]
    convert_to_mp4(video, folder_src)

if __name__ == "__main__":
    main(sys.argv)
