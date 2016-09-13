import Prelude
import Result
import XCTest
@testable import Library
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers

internal final class ActivityUpdateViewModelTests: TestCase {
  private let vm: ActivityUpdateViewModelType = ActivityUpdateViewModel()
  private let body = TestObserver<String, NoError>()
  private let cellAccessibilityLabel = TestObserver<String, NoError>()
  private let cellAccessibilityValue = TestObserver<String, NoError>()
  private let notifyDelegateTappedProjectImage = TestObserver<Activity, NoError>()
  private let projectButtonAccessibilityLabel = TestObserver<String, NoError>()
  private let projectImageURL = TestObserver<String?, NoError>()
  private let projectName = TestObserver<String, NoError>()
  private let sequenceTitle = TestObserver<String, NoError>()
  private let timestamp = TestObserver<String, NoError>()
  private let title = TestObserver<String, NoError>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.body.observe(self.body.observer)
    self.vm.outputs.cellAccessibilityLabel.observe(self.cellAccessibilityLabel.observer)
    self.vm.outputs.cellAccessibilityValue.observe(self.cellAccessibilityValue.observer)
    self.vm.outputs.notifyDelegateTappedProjectImage.observe(self.notifyDelegateTappedProjectImage.observer)
    self.vm.outputs.projectButtonAccessibilityLabel.observe(self.projectButtonAccessibilityLabel.observer)
    self.vm.outputs.projectImageURL.map { $0?.absoluteString }.observe(self.projectImageURL.observer)
    self.vm.outputs.projectName.observe(self.projectName.observer)
    self.vm.outputs.sequenceTitle.observe(self.sequenceTitle.observer)
    self.vm.outputs.timestamp.observe(self.timestamp.observer)
    self.vm.outputs.title.observe(self.title.observer)
  }

  func testActivityUpdateDataEmits() {
    let project = Project.template
    let update = Update.template
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)

    self.body.assertValues([update.body?.htmlStripped()?.truncated(maxLength: 300) ?? ""])
    self.projectButtonAccessibilityLabel.assertValues([project.name])
    self.projectImageURL.assertValues([project.photo.med])
    self.projectName.assertValues([project.name])
    self.sequenceTitle.assertValues([Strings.activity_project_update_update_count(update_count:
      Format.wholeNumber(update.sequence))])
    self.timestamp.assertValues([Format.date(secondsInUTC: activity.createdAt, dateStyle: .MediumStyle,
      timeStyle: .NoStyle)])
    self.title.assertValues([update.title])
  }

  func testCellAccessibilityDataEmits() {
    let project = Project.template
    let update = Update.template
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)

    self.cellAccessibilityLabel.assertValues([Strings.activity_project_update_update_count(update_count:
      Format.wholeNumber(update.sequence))], "Cell a11y label emits sequence title.")
    self.cellAccessibilityValue.assertValues([update.title], "Cell a11y value emits update title.")
  }

  func testTappedProjectImageButton() {
    let project = Project.template
    let update = Update.template
    let activity = .template
      |> Activity.lens.project .~ project
      |> Activity.lens.update .~ update

    self.vm.inputs.configureWith(activity: activity)
    self.vm.inputs.tappedProjectImage()
    self.notifyDelegateTappedProjectImage.assertValues([activity])
  }
}