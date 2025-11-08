import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close(event) {
    event.preventDefault()
    // モーダルフレームを空にする（Turbo的に正しい閉じ方）
    this.element.innerHTML = ""

    // モーダル（dialogタグ）全体を閉じる
    const dialog = this.element.closest("dialog") || this.element
    dialog.close?.() // HTML標準のclose()メソッド呼び出し

    // Turbo frameの中身もクリアして完全に削除
    const modalFrame = document.getElementById("modal")
    if (modalFrame) modalFrame.innerHTML = ""
  }
}
