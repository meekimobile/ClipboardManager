package com.mranuran.clipboardmanager;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ClipboardManagerPlugin */
public class ClipboardManagerPlugin implements MethodCallHandler {
    private static final String TAG = "ClipboardManagerPlugin";

	private Registrar registrar;
	private HashMap<String, String> fileExtMap;

	private ClipboardManagerPlugin(Registrar registrar){
		this.registrar=registrar;
	}

	/** Plugin registration. */
	public static void registerWith(Registrar registrar) {
		final MethodChannel channel = new MethodChannel(registrar.messenger(), "clipboard_manager");
		ClipboardManagerPlugin instance = new ClipboardManagerPlugin(registrar);
		channel.setMethodCallHandler(instance);
	}

	private Context getContext() {
		Context context;
		if (registrar.activity() != null) {
			context = (Context) registrar.activity();
		} else {
			context = registrar.context();
		}
		return context;
	}

	@Override
	public void onMethodCall(MethodCall call, Result result) {
		if (call.method.equals("copyToClipBoard")) {
			String contentType = call.argument("contentType");
			if (contentType == null) {
				result.error("invalid_content_type", "Invalid content type.", null);
				return;
			}

			ClipboardManager clipboard = (ClipboardManager)getContext().getSystemService(Context.CLIPBOARD_SERVICE);

			if (contentType.startsWith("text/")) {
				String thingToCopy = call.argument("content");
				ClipData clip = ClipData.newPlainText("", thingToCopy);
				clipboard.setPrimaryClip(clip);
				result.success(true);

			} else if (contentType.startsWith("image/")) {
				byte[] thingToCopy = call.argument("content");
				Uri savedFileUri = saveBinaryFile(thingToCopy, contentType);
				ClipData clip = new ClipData("binary", new String[]{contentType}, new ClipData.Item(savedFileUri));
				clipboard.setPrimaryClip(clip);
				result.success(true);

			} else {
				result.notImplemented();
			}

		} else if (call.method.equals("pasteFromClipBoard")) {
			ClipboardManager clipboard = (ClipboardManager)getContext().getSystemService(Context.CLIPBOARD_SERVICE);
			if (clipboard.hasPrimaryClip() && clipboard.getPrimaryClip().getItemCount() > 0) {
				ClipData.Item item = clipboard.getPrimaryClip().getItemAt(0);
				String contentType = clipboard.getPrimaryClip().getDescription().getMimeType(0);
				HashMap<String, Object> resMap = new HashMap<>();
				resMap.put("contentType", contentType);

				if (contentType.startsWith("text/plain")) {
					resMap.put("content", item.getText().toString());
					result.success(resMap);

				} else if (contentType.startsWith("text/html")) {
					resMap.put("content", item.getHtmlText());
					result.success(resMap);

				} else if (contentType.startsWith("image/")) {
					resMap.put("content", getBytesFromImageUri(item.getUri()));
					result.success(resMap);

				} else {
					result.error("unsupported_content_type", "Unsupported content type.", null);
				}

			} else {
				HashMap<String, Object> resMap = new HashMap<>();
				resMap.put("contentType", "null");
				result.success(resMap);
			}

		} else {
			result.notImplemented();
		}
	}

    private byte[] getBytesFromImageUri(Uri imageUri) {
        try {
            InputStream is = getContext().getContentResolver().openInputStream(imageUri);
			ByteArrayOutputStream result = new ByteArrayOutputStream();
			byte[] buffer = new byte[1024];
			int length;
			while ((length = is.read(buffer)) != -1) {
				result.write(buffer, 0, length);
			}
            return result.toByteArray();

        } catch (Exception e) {
            Log.e(TAG, "getBytesFromImageUri", e);
            return null;
        }
    }

    private String contentType2FileExt(String contentType) {
        if (fileExtMap == null) {
            fileExtMap = new HashMap<>();
            fileExtMap.put("image/jpg", "jpg");
            fileExtMap.put("image/jpeg", "jpg");
            fileExtMap.put("image/png", "png");
            fileExtMap.put("image/gif", "gif");
            fileExtMap.put("image/tiff", "tif");
        }

        return fileExtMap.get(contentType);
    }

	private Uri saveBinaryFile(byte[] data, String contentType) {
		try {
			// TODO: Save to image file, then create Uri with FileProvider.
			String fileExtension = contentType2FileExt(contentType);
			File homeDir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "ClipboardAnywhere");
			homeDir.mkdirs();
			File imageFile = new File(homeDir, String.format(Locale.getDefault(), "ClipboardAnywhere-%d.%s", new Date().getTime(), fileExtension));
			FileOutputStream fos = new FileOutputStream(imageFile);
			// TODO: Async writing.
			fos.write(data, 0, data.length);
			fos.close();
			Uri dataUri = Uri.fromFile(imageFile);

			return dataUri;

		} catch (Exception e) {
            Log.e(TAG, "saveBinaryFile", e);
			return null;
		}
	}
}
