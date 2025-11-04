import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "content"]

  // モーダルを開く
  open() {
    if (!this.hasContentTarget) return
    if (this.contentTarget.innerHTML.trim() === "") return

    this.dialogTarget.showModal()
  }

  // モーダルを閉じる
  close(event) {
    const currentTarget = event?.currentTarget

    if (currentTarget === this.dialogTarget) {
      const clickedBackdrop = event.target === this.dialogTarget
      if (!clickedBackdrop) return
    }

    this.dialogTarget.close()
    this.resetContent()
  }

  resetContent() {
    if (!this.hasContentTarget) return
    this.contentTarget.innerHTML = ""
  }
}
