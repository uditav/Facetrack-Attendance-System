from flask import Flask, request, jsonify
import cv2
import os
from deepface import DeepFace
from retinaface import RetinaFace
import shutil

app = Flask(__name__)

@app.route('/process_video', methods = ['GET'])
def returnresult():
	videoIndex = str(request.args['q'])
	if(videoIndex=='1'):
		result = faceRecognition()
	else:
		result = {"present":"wrong input"}

	return jsonify(result)

def faceRecognition():
    #if 'video' not in request.files:
        #return jsonify({'message': 'No video part in the request'}), 400
    #temp_folder = 'temp_upload'
    #os.makedirs(temp_folder, exist_ok=True)
    #video_file = request.files['video']
    #if video_file.filename == '':
        #shutil.rmtree(temp_folder)  # Clean up by removing the folder
        #return jsonify({'error': 'No selected file'})
    
    #video_path = os.path.join(temp_folder, video_file.filename)
    #video_file.save(video_path)

    #return {"message" : video_path}
    video_path = './uploaded_video.mp4'

    video = cv2.VideoCapture(video_path)
    if not video.isOpened():
        print('no video')
        return {"error":0}
    
    fps = video.get(cv2.CAP_PROP_FPS)

    number_of_frames_required = 10
    os.mkdir('frames')
    os.mkdir('refinedImages')
    for extracted_frame in range(number_of_frames_required):
        frame_id = int(fps * extracted_frame)
        video.set(cv2.CAP_PROP_POS_FRAMES, frame_id)
        ret, frame = video.read()
        if not ret:
            break

        # Save the extracted frames
        cv2.imwrite('./frames/' + str(extracted_frame) + '.png', frame)

    cropped = 0
    number_of_frames_required = 10
    
    for frame_number in range(number_of_frames_required):
        frame = cv2.imread('./frames/' + str(frame_number) + '.png')

        # Face detection using RetinaFace
        faces = RetinaFace.detect_faces(frame)

        if isinstance(faces, dict):
            for key, face_data in faces.items():
                # Coordinates of the face
                facial_area = face_data["facial_area"]
                x1, y1, x2, y2 = facial_area

                # Crop face
                cropped_face = frame[y1:y2, x1:x2]
                cv2.imwrite("./refinedImages/" + str(cropped) + ".png", cropped_face)
                cropped += 1

    present = []

    for cropped_img in range(cropped):
        for filename in os.listdir("./tmp"):  # Assuming 'tmp' folder contains the student faces database
            roll_number = str(filename).split(".")[0]

            if roll_number not in present:
                img1_path = f"./refinedImages/{cropped_img}.png"
                img2_path = f"./tmp/{filename}"

                img1 = cv2.imread(img1_path)
                img2 = cv2.imread(img2_path)

                if img1 is None or img2 is None:
                    print(f"Error reading images {img1_path} or {img2_path}")
                    continue

                # Use DeepFace's ArcFace for recognition
                try:
                    result = DeepFace.verify(img1_path, img2_path, model_name='ArcFace', enforce_detection=False)
                    if result["verified"]:
                        present.append(roll_number)
                except Exception as e:
                    print(f"Error in face verification: {e}")
                    continue
    
    shutil.rmtree('./frames')
    shutil.rmtree('./refinedImages')
    #shutil.rmtree(temp_folder)
    students = {}
    students['present'] = present

    return students

if __name__ == "__main__":
	app.run(debug=True)