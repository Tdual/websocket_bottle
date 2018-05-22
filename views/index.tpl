<!DOCTYPE html>
<html>
  <head>
    <!-- Add this to <head> -->
    <link type="text/css" rel="stylesheet" href="//unpkg.com/bootstrap/dist/css/bootstrap.min.css"/>
    <link type="text/css" rel="stylesheet" href="//unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.css"/>

    <script src="https://unpkg.com/vue"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>

    <!-- Add this after vue.js -->
    <script src="//unpkg.com/babel-polyfill@latest/dist/polyfill.min.js"></script>
    <script src="//unpkg.com/bootstrap-vue@latest/dist/bootstrap-vue.js"></script>

  </head>
  <body>
    <H1> WebSocket Sample </H1>
    <div id="app">
        <b-form-file class="w-50 p-3 mb-1 bg-secondary" @change="selectedFile" placeholder="Choose a CSV file..."></b-form-file>
        <button v-on:click="send" v-bind:disabled="!uploadFile">Upload</button>
        <p v-if="progress > 0">
          <b-progress height="30px" :value="progress" :max="uploadFile.size" show-progress animated></b-progress>
        </p>
      <div>
        ${result}
      </div>
    </div>
  </body>
  <script type="text/javascript">

    var host = "localhost:8000";
    var url = "ws://"+host+"/websocket";

    var ws = new WebSocket(url);

    ws.onopen = function(){console.log("ws open.");};
    ws.onclose = function(){ console.log("we close.");};

    ws.onmessage = function (evt) {
        var res  = JSON.parse(evt.data)
        console.log(res);
        var loadedSize = res["loadedSize"]
        if(loadedSize){
          vm.progress = loadedSize;
        }else{
          console.log(res);
        }
    };

    function parseFile(file, chunkSize){
        var fileSize = file.size;

        var readerLoad = function(e){
          var body = e.target.result;
          ws.send(body);
        };

        for(var i = 0; i < fileSize; i += chunkSize) {
          console.log(i);
          (function(fil, start) {
              var reader = new FileReader();
              var blob = fil.slice(start, chunkSize + start);
              reader.onload = readerLoad;
              //reader.readAsText(blob);
              reader.readAsArrayBuffer(blob)
          })(file, i);
        }
    }

    let vm = new Vue({
      delimiters: ['${', '}'],
      el: '#app',
      data: {
        uploadFile: null,
        uploaded: false,
        progress: 0,
        result: ""
      },
      methods: {
        selectedFile: function(e){
          e.preventDefault();
          console.log("uploaded");
          let files = e.target.files;
          this.uploadFile = files[0];
        },

        send: function(){
          var fileSize = this.uploadFile.size
          var request = {
            action: "upload",
            fileSize: fileSize
          }
          this.progress = 1;
          ws.send(JSON.stringify(request));
          parseFile(this.uploadFile, 20);
        }
      }
    });
  </script>
</html>
