import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  // モーダルを開く
  open() {
    this.dialogTarget.showModal()
  }

  // モーダルを閉じる
  close(event) {
    // currentTargetがdialogで、かつクリックされた要素がdialog自身の場合はモーダル外クリックと判定して閉じる
    const clickedOutside = event?.currentTarget?.nodeName === "DIALOG" && event.target === this.dialogTarget
    if (clickedOutside) {
      this.dialogTarget.close()
      return
    }

    // 閉じるボタンなどからの呼び出しの場合はそのまま閉じる
    this.dialogTarget.close()
  }
}
