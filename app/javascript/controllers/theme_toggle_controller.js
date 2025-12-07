import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "iconLight", "iconDark"]

  connect() {
    const saved = localStorage.getItem("koko-theme")
    const fallback = document.documentElement.getAttribute("data-theme") || "kokolog"
    const theme = saved || fallback

    document.documentElement.setAttribute("data-theme", theme)
    this.checkboxTarget.checked = theme.includes("dark")

    this.updateIcons()
  }

  switch() {
    const newTheme = this.checkboxTarget.checked
      ? "kokolog-dark"
      : "kokolog"

    document.documentElement.setAttribute("data-theme", newTheme)
    localStorage.setItem("koko-theme", newTheme)

    this.updateIcons()
  }

  updateIcons() {
    if (this.checkboxTarget.checked) {
      // ダークテーマ → 月アイコン表示
      this.iconLightTarget.classList.add("hidden")
      this.iconDarkTarget.classList.remove("hidden")
    } else {
      // ライトテーマ → 太陽アイコン表示
      this.iconDarkTarget.classList.add("hidden")
      this.iconLightTarget.classList.remove("hidden")
    }
  }
}
