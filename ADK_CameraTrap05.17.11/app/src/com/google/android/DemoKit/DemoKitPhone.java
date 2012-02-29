package com.google.android.DemoKit;

import java.io.File;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class DemoKitPhone extends BaseActivity implements OnClickListener {
	static final String TAG = "DemoKitPhone";
	/** Called when the activity is first created. */
	TextView mInputLabel;
	TextView mOutputLabel;
	LinearLayout mInputContainer;
	LinearLayout mOutputContainer;
	Drawable mFocusedTabImage;
	Drawable mNormalTabImage;
	OutputController mOutputController;
	ImageView ourImageView;
    public static final int CAMERA_RESULT = 0;
    String imageFilePath;
	
	@Override
	protected void hideControls() {
		super.hideControls();
		mOutputController = null;
	}

	public void onCreate(Bundle savedInstanceState) {
		mFocusedTabImage = getResources().getDrawable(
				R.drawable.tab_focused_holo_dark);
		mNormalTabImage = getResources().getDrawable(
				R.drawable.tab_normal_holo_dark);
		super.onCreate(savedInstanceState);
		
		  imageFilePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/tmp3.jpg";
	}

	protected void showControls() {
		super.showControls();
		mOutputController = new OutputController(this, false);
		mOutputController.accessoryAttached();
		mInputLabel = (TextView) findViewById(R.id.inputLabel);
		mOutputLabel = (TextView) findViewById(R.id.outputLabel);
		mInputContainer = (LinearLayout) findViewById(R.id.inputContainer);
		mOutputContainer = (LinearLayout) findViewById(R.id.outputContainer);
		mInputLabel.setOnClickListener(this);
		mOutputLabel.setOnClickListener(this);

		showTabContents(true);
	}

	void showTabContents(Boolean showInput) {
		
		if (showInput) {
			mInputContainer.setVisibility(View.VISIBLE);
			mInputLabel.setBackgroundDrawable(mFocusedTabImage);
			mOutputContainer.setVisibility(View.GONE);
			mOutputLabel.setBackgroundDrawable(mNormalTabImage);
		} else {
			mInputContainer.setVisibility(View.GONE);
			mInputLabel.setBackgroundDrawable(mNormalTabImage);
			mOutputContainer.setVisibility(View.VISIBLE);
			mOutputLabel.setBackgroundDrawable(mFocusedTabImage);
		}
		
		
	} 
	
	public void takeTheDamnPicture() {

		String imageFilePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/tmp3.jpg";
		File imageFile = new File(imageFilePath);
		Uri imageFileUri = Uri.fromFile(imageFile);
		
		
		Intent i = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
		i.putExtra(android.provider.MediaStore.EXTRA_OUTPUT, imageFileUri);

		startActivityForResult(i, CAMERA_RESULT);
	}
	
	public void startActivityForResult(Intent i, int cameraResult) {
			// TODO Auto-generated method stub
	}
	
	 protected void onActivityResult(int requestCode, int resultCode, Intent intent) 
	    {       		
			super.onActivityResult(requestCode, resultCode, intent);

			//Bundle extras = intent.getExtras();
					
			switch(requestCode) 
			{
				case CAMERA_RESULT:
					
					if (resultCode == RESULT_OK)
					{
						Log.v("RESULTS","HERE");

						/* Tiny Image Returned
						Bitmap bmp = (Bitmap) extras.get("data");
						ourImageView.setImageBitmap(bmp);
						*/
					    
						Bitmap bmp = BitmapFactory.decodeFile(imageFilePath);
						ourImageView.setImageBitmap(bmp);
						
						Log.v("RESULTS","Image Width: " + bmp.getWidth());
						Log.v("RESULTS","Image Height: " + bmp.getHeight());					
					}
					break;    
			}
	    }
	
			
	public void onClick(View v) {
		int vId = v.getId();
		switch (vId) {
		case R.id.inputLabel:
			showTabContents(true);
			break;

		case R.id.outputLabel:
		
			//showTabContents(false);
			takeTheDamnPicture();
			break;
		}
	}

}