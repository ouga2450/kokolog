import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  // モーダルを開く
  open() {
    if (!this.hasContentTarget) return
    if (this.contentTarget.innerHTML.trim() === "") return

    this.element.classList.remove("hidden")
  }

  // モーダルを閉じる
  close() {
    this.element.classList.add("hidden")
    this.clearContent()
  }

  // コンテンツ領域でのクリックは閉じない
  stopPropagation(event) {
    event.stopPropagation()
  }

  // コンテンツ領域をリセット
  clearContent() {
    const frame = this.contentTarget.querySelector("#modal_content")
    if (frame) frame.innerHTML = ""
  }
}
