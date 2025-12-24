import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"
import "chartjs-adapter-date-fns"

function themeColor(variable) {
  return getComputedStyle(document.documentElement)
    .getPropertyValue(variable)
    .trim()
}

export default class extends Controller {
  static values = {
    values: Array
  }

  connect() {
    if (!this.valuesValue || this.valuesValue.length === 0) return

    const canvas = this.element.querySelector("canvas")

    // テーマカラー取得
    const primary     = themeColor("--color-primary")
    const base200     = themeColor("--color-base-200")
    const base300     = themeColor("--color-base-300")
    const baseContent = themeColor("--color-base-content")
    const neutral     = themeColor("--color-neutral")
    const accent      = themeColor("--color-accent")

    // 時系列データ
    const data = this.valuesValue.map(v => ({
      x: new Date(v[0]),
      y: v[1]
    }))

    this.chart = new Chart(canvas, {
      type: "line",
      data: {
        datasets: [
          {
            data,
            borderColor: primary,
            backgroundColor: "transparent",
            borderWidth: 2,
            tension: 0.35,
            pointRadius: 3,
            pointBackgroundColor: primary,
            pointBorderColor: base200,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: accent
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: base200,
            titleColor: baseContent,
            bodyColor: baseContent,
            borderColor: base300,
            borderWidth: 1,
            displayColors: false,
            callbacks: {
              title: (items) => {
                const date = items[0].parsed.x
                return date.toLocaleTimeString("ja-JP", {
                  hour: "2-digit",
                  minute: "2-digit"
                })
              },
              label: (context) => {
                return `気分：${context.parsed.y}`
              }
            }
          }
        },
        scales: {
          x: {
            type: "time",
            time: {
              unit: "hour",
              stepSize: 2,
              displayFormats: {
                hour: "HH:mm"
              }
            },
            grid: {
              color: base300,
              borderDash: [2, 2]
            },
            ticks: {
              color: neutral,
              autoSkip: false,
              maxRotation: 0,
              font: { size: 11 }
            }
          },
          y: {
            min: 1,
            max: 5,
            grid: {
              color: base300,
              borderDash: [2, 2]
            },
            ticks: {
              stepSize: 1,
              color: neutral,
              font: { size: 11 }
            }
          }
        }
      }
    })
  }

  disconnect() {
    if (this.chart) this.chart.destroy()
  }
}
