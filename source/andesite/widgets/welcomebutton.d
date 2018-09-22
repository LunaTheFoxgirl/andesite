module andesite.widgets.welcomebutton;
import andesite.styleclass;
import gtk.Button;
import gtk.Label;
import gtk.Grid;
import gtk.Image;

class WelcomeButton : Button {
private:
	Label buttonTitle;
	Label buttonDescription;
	Image icon_;
	Grid buttonGrid;
public:
	@property string title() {
		return buttonTitle.getText();
	}

	@property void title(string val) {
		buttonTitle.setText(val);
	}

	@property string description() {
		return buttonDescription.getText();
	}

	@property void description(string val) {
		buttonDescription.setText(val);
	}

	@property Image icon() {
		return icon_;
	}

	@property void icon(Image val) {
		if (icon_ !is null) {
			icon_.destroy();
		}
		icon_ = val;
		if (icon_ !is null) {
			icon_.setPixelSize(48);
			icon_.setHalign(Align.CENTER);
			icon_.setValign(Align.CENTER);
			buttonGrid.attach(icon_, 0, 0, 1, 2);
		}
	}

	this(Image image, string optionText, string descriptionText) {
		buttonTitle = new Label("");
		buttonTitle.getStyleContext.addClass(StyleClass.H3Label);
		buttonTitle.setHalign(Align.START);
		buttonTitle.setValign(Align.END);

		buttonDescription = new Label("");
		buttonDescription.setHalign(Align.START);
		buttonDescription.setValign(Align.START);
		buttonDescription.setLineWrap(true);
		buttonDescription.setLineWrapMode(PangoWrapMode.WORD);
		buttonDescription.getStyleContext.addClass(STYLE_CLASS_DIM_LABEL);

		this.getStyleContext.addClass(STYLE_CLASS_FLAT);

		buttonGrid = new Grid();
		buttonGrid.setColumnSpacing(12);

		buttonGrid.attach(buttonTitle, 1, 0, 1, 1);
		buttonGrid.attach(buttonDescription, 1, 1, 1, 1);
		this.add(buttonGrid);

		title = optionText;
		description = descriptionText;
		icon = image;
	}
}