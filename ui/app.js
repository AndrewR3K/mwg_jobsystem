const { createApp } = Vue

createApp({
  data() {
    return {
      jobs: {},
      jobDetails: {},
      currentXpPercentage: 0,
      jobuiVisible: false,
      visible: false,
      maxLevel: false,
    }
  },
  mounted() {
    window.addEventListener('message', this.onMessage);
    window.addEventListener('keypress', this.onKeyPress);
  },
  destroyed() {
    window.removeEventListener('message');
    window.addEventListener('keydown', this.onKeyPress);
  },
  methods: {
    onMessage(event) {
      if (event.data.type === 'open') {
        this.visible = true
        this.jobuiVisible = false
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

      if (event.data.type === 'jobUI') {
        this.visible = false
        this.jobuiVisible = true
        this.jobs = event.data.jobs
      }
    },
    onKeyPress(event) {
      if (event.keyCode == 27 || event.key == 'Escape') {
        this.closeUI()
      }
    },
    selectJob(job) {
      fetch(`https://${GetParentResourceName()}/jobUIClose`, {
        method: 'POST',
        body: JSON.stringify({
          job: job,
          action: "setJob"
        })
      })
      this.jobuiVisible = false
    },
    quitJob(job) {
      fetch(`https://${GetParentResourceName()}/jobUIClose`, {
        method: 'POST',
        body: JSON.stringify({
          job: job,
          action: "quitJob"
        })
      })
      this.visible = false
      this.jobuiVisible = false
    },
    closeUI() {
      fetch(`https://${GetParentResourceName()}/jobUIClose`, {
        method: 'POST',
        body: JSON.stringify({
          action: "close"
        })
      })
      this.jobuiVisible = false
      this.jobs = {}
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