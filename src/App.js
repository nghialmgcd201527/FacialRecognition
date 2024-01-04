import { useState } from 'react';
import './App.css';
const uuid = require('uuid');

function App() {
  const [image, setImage] = useState('');
  const [uploadResultMessage, setUploadResultMessage] = useState('Please upload an image to authentication.')
  const [visitorName, setVisitorName] = useState('placeholder.png')
  const [isAuth, setAuth] = useState(false)
  const [registerImage, setRegisterImage] = useState('');


  function sendRegisterImage(e) {
    console.log(e.target.files);
    setRegisterImage(e.target.files[0]);
  }

  function sendImage(e) {
    e.preventDefault();
    setVisitorName(image.name)
    const visitorImageName = uuid.v4();
    fetch(`https://od7i9slbdl.execute-api.ap-southeast-1.amazonaws.com/dev/minhnghia-employee-image-storage/${visitorImageName}.jpeg`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'image/jpeg'
      },
      body: image
    }).then(async () => {
      const response = await authenticate(visitorImageName)
      if (response.Message === 'Success') {
        setAuth(true)
        setUploadResultMessage(`Hi ${response['firstName']} ${response['lastName']}, welcome to work. Hope you have a productive day!`)
      } else {
        setAuth(false)
        setUploadResultMessage('Authentication Failed: this person is not an employee.')
      }
    }).catch(error => {
      setAuth(false)
      setUploadResultMessage('There is an error during the authentication process. Please try again.')
      console.error(error)
    })
  }

  async function authenticate(visitorImageName) {
    const requestUrl = 'https://od7i9slbdl.execute-api.ap-southeast-1.amazonaws.com/dev/employee?' + new URLSearchParams({
      objectKey: `${visitorImageName}.jpeg`
    });
    return await fetch(requestUrl, {  
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
        // 'Access-Control-Allow-Origin': 'http://localhost:5500',
        // 'Access-Control-Allow-Methods': 'GET',
        // 'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Origin'
      }
    }).then(response => response.json())
    .then((data) => {
      return data;
    }).catch(error => console.error(error))
  }

  return (
    <div className="App">
      <h2>LeMinhNghia's Facial Recognition System</h2>
      <div>
      <h3>Upload New Register Image</h3>
        <form>
          <input type='file' name='registerImage' onChange={sendRegisterImage}/>
        </form>
      </div>
      <div className={isAuth ? 'success' : 'failure'}>{uploadResultMessage}</div>
      <form onSubmit={sendImage}>
        <input type='file' name='image' onChange={e => setImage(e.target.files[0])}/>
        <button type='submit'>Authentication</button>
      </form>
      <img src={ require(`./visitors/${visitorName}`) } alt='Visitor' height={250} width={250}/>
    </div>
  );
}

export default App;
