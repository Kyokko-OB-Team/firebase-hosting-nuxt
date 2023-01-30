<template>
  <div>
    <Tutorial/>
    <h1>今の温度</h1>
    <p>センサ名 : {{ res_data.name }}</p>
    <p>測定時間 : {{ res_data.time }}</p>
    <p>       気温 : {{ res_data.temperature }}</p>
    <p>       湿度 : {{ res_data.humidity }}</p>
    <p>       CO2濃度 : {{ res_data.co2Concentration }}</p>
    <br>
    <br>
    <h1>グラフ</h1>
    <vue-c3 :handler="handler"> </vue-c3>
  </div>
</template>

<script>
import Vue from 'vue'
import { initializeApp } from 'firebase/app'
import { getFirestore } from 'firebase/firestore/lite'
import VueC3 from 'vue-c3'
import 'c3/c3.min.css'

const firebaseApp = initializeApp ({
  projectId: 'kyokko-ob-team-8a210'
});
const db = getFirestore(firebaseApp);

export default {
  components: {
    VueC3
  },

  data () {
    return {
      time: [],
      temperatures: [],
      humidity: [],
      co2concentration: [],
      handler: new Vue(),
    }
  },

  methods: {
    async getRoomTemp () {
      await db.collection('sensor-data_test-env')
          .orderBy('time')
          .limit(72)
          .get()
          .then(querySnapshot => {
            this.room_data = querySnapshot.docs.map(doc => {
              const data = doc.data()
              return {
                time: data.time.toLocaleDateString() + data.time.toLocaleTimeString(),
                temperatures: data.temperatures,
                humidity: data.humidity,
                co2concentration: data.co2Concentration,
              };
            });
          });
    }
  },

  async initGraph () {
    await this.getRoomTemp();
    const options = {
      data: {
        x: 'x',
        columns: [
          ['x'].concat(this.room_data.map(data => { return data.time })),
          ['温度(℃)'].concat(this.room_data.map(data => { return data.temperatures })),
          ['湿度(%)'].concat(this.humidity.map(data => { return data.humidity })),
          ['CO2濃度(ppm)'].concat(this.co2Concentration.map(data => { return data.co2Concentration })),
        ]
      },
      axis: {
        x: {
          type: 'timeseries',
          tick: {
            format: '%Y-%m-%d %H:%M'
          },
          label: {
            text: "time",
            position: 'outer-middle'
          },
        },
        y: {
          label: {
            text: "温度(℃)",
            position: 'outer-middle'
          },
        },
        y2: {
          label: {
            text: "湿度(%)",
            position: 'outer-middle'
          },
          max: 100,
          min: 0,
        }
      }
    }
    this.handler.$emit('init', options);
  },

  mounted () {
    this.initGraph();
  },

  async asyncData ({ $axios }) {
    const url = 'https://us-central1-kyokko-ob-team-8a210.cloudfunctions.net/getLatestDocument';    // getLatestDocument()のurl
    const param_data_collection = 'sensor-data_test-env';

    // APIを叩く
    const res_data = await $axios.$get(
      url, {
        params: {
          // パラメータ指定
          collection: param_data_collection,
        }
      }
    );
    console.log(res_data);
    return { res_data };
  }
}
</script>

<style>
  body {
    color: #E8EAED;
    background-color: #202124;
  }
  h1 {
    border-bottom: solid 3px #E8EAED;
    border-top: solid 3px #E8EAED;
    padding: 10px 0 8px 25px;
    font-size: 40px;
  }
</style>