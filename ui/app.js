const { createApp } = Vue

createApp({
  data() {
    return {
      jobDetails: {},
      currentXpPercentage: 0,
      visible: false,
      maxLevel: false,
    }
  },
  mounted() {
    window.addEventListener('message', this.onMessage);
  },
  destroyed() {
    window.removeEventListener('message')
  },
  methods: {
    onMessage(event) {
      if (event.data.type === 'open') {
        this.visible = true
        this.jobDetails = event.data.jobData
        this.updateJobBar()
      }

      if (event.data.type === 'update') {
        this.jobDetails = event.data.jobData
        this.updateJobBar()
      }

      if (event.data.type === 'close') {
        this.visible = false
      }
    },
    updateJobBar() {
      if (this.jobDetails.level === this.jobDetails.nextLevel) {
        this.maxLevel = true
      } else {
        this.currentXpPercentage = Math.round((this.jobDetails.totalXp - this.jobDetails.currentLevelMinXp) / (this.jobDetails.nextLevelXp - this.jobDetails.currentLevelMinXp) * 100)
        this.maxLevel = false
      }
    },
  }
}).mount('#app')