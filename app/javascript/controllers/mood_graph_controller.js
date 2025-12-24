import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static values = {
    values: Array
  }

  connect() {
    if (!this.valuesValue || this.valuesValue.length === 0) return

    const canvas = this.element.querySelector("canvas")

    const labels = this.valuesValue.map(v =>
      new Date(v[0]).toLocaleTimeString("ja-JP", {
        hour: "2-digit",
        minute: "2-digit"
      })
    )

    const data = this.valuesValue.map(v => v[1])

    this.chart = new Chart(canvas, {
      type: "line",
      data: {
        labels,
        datasets: [{
          data,
          borderColor: "rgba(100, 116, 139, 0.8)", // slate-500
          backgroundColor: "rgba(100, 116, 139, 0.15)",
          fill: true,
          tension: 0.35,
          pointRadius: 2,
          pointHoverRadius: 4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false }
        },
        scales: {
          x: { display: false },
          y: {
            min: 1,
            max: 5,
            ticks: {
              stepSize: 1
            }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }
}
