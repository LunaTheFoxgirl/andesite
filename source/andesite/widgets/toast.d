module andesite.widgets.toast;
import andesite.styleclass;
import gtk.Grid;
import gtk.Frame;
import gtk.Button;
import gtk.Revealer;
import gtk.Label;
import glib.Source;
import glib.Timeout;
import sev.event;

public class Toast : Revealer {
private:

	Label notificationLabel;
	Button defaultActionButton;
	string title_;
	uint timeoutId;

	void defaultDelegate(Button b) {
			this.setRevealChild(false);
			if (timeoutId != 0) {
				Source.remove(timeoutId);
				timeoutId = 0;
			}

			if (defaultAction !is null)
				defaultAction(null, null);
	}

	void closedDelegate(Button b) {
			this.setRevealChild(false);
			if (timeoutId != 0) {
				Source.remove(timeoutId);
				timeoutId = 0;
			}

			if (closed !is null) 
				closed(null, null);
	}

public: 
	Event closed = new Event();

	Event defaultAction = new Event();

	@property string title() {
		return title_;
	}

	@property void title(string val) {
		if (notificationLabel !is null) notificationLabel.setLabel(val);
		title_ = val;
	}

	this(string title) {
		this.setMarginBottom(3);
		this.setMarginTop(3);
		this.setMarginLeft(3);
		this.setMarginRight(3);
		this.setHalign(Align.CENTER);
		this.setValign(Align.START);

		defaultActionButton = new Button();
		defaultActionButton.setVisible(false);
		defaultActionButton.setNoShowAll(true);
		defaultActionButton.addOnClicked(&defaultDelegate);

		Button closeButton = new Button();
		closeButton.getStyleContext.addClass("close-button");
		closeButton.addOnClicked(&closedDelegate);

		notificationLabel = new Label(title);

		Grid notificationBox = new Grid();
		notificationBox.setColumnSpacing(12);
		notificationBox.add(closeButton);
		notificationBox.add(notificationLabel);
		notificationBox.add(defaultActionButton);

		Frame notificationFrame = new Frame("");
		notificationFrame.getStyleContext.addClass("app-notification");
		notificationFrame.add(notificationBox);

		add(notificationFrame);

		this.title = title;
	}

	void setDefaultAction(string label) {
		if (label == "" || label is null) {
			defaultActionButton.setNoShowAll(true);
			defaultActionButton.setVisible(false);
		} else {
			defaultActionButton.setNoShowAll(false);
			defaultActionButton.setVisible(true);
		}
		defaultActionButton.setLabel(label);
	}

	void sendNotification() {
		if (!getChildRevealed) {
			setRevealChild(true);

			uint duration = (defaultActionButton.getVisible ? 3500 : 2000);

			timeoutId = Timeout.add(duration, &timeoutManFunc, cast(void*)this);
		}
	}
}

// Function that wraps timeout managment.
private extern(C) int timeoutManFunc(void* data) {
	Toast self = cast(Toast)data;
	self.setRevealChild(false);
	self.timeoutId = 0;
	return 0;
}