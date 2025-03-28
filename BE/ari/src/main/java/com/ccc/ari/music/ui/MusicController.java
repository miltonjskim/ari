package com.ccc.ari.music.ui;

import com.ccc.ari.global.error.ErrorCode;
import com.ccc.ari.global.security.MemberUserDetails;
import com.ccc.ari.global.util.ApiUtils;
import com.ccc.ari.music.application.command.TrackPlayCommand;
import com.ccc.ari.music.application.command.UploadAlbumCommand;
import com.ccc.ari.music.application.serviceImpl.MusicServiceImpl;
import com.ccc.ari.music.ui.request.UploadAlbumRequest;
import com.ccc.ari.music.ui.response.TrackPlayResponse;
import com.ccc.ari.music.ui.response.UploadAlbumResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/v1/albums")
@RequiredArgsConstructor
@Slf4j
public class MusicController {

    private final MusicServiceImpl musicService;
    private final ObjectMapper objectMapper; // JSON 변환용

    // 음원 재생
    @PostMapping("/{albumId}/tracks/{trackId}")
    public ApiUtils.ApiResponse<TrackPlayResponse> trackPlay(
            @PathVariable Integer albumId,
            @PathVariable Integer trackId,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails) {

        return ApiUtils.success(musicService.trackPlay(TrackPlayCommand.builder()
                .albumId(albumId)
                .trackId(trackId)
                .memberId(memberUserDetails.getMemberId())
                .nickname(memberUserDetails.getNickname())
                .build()));
    }

    @PostMapping("/upload")
    public ApiUtils.ApiResponse<?> uploadAlbum(
            @RequestPart(value = "coverImage", required = true) MultipartFile coverImage,
            @RequestPart(value = "tracks", required = true) List<MultipartFile> tracks,
            @RequestPart(value = "metadata", required = true) String metadata,
            @AuthenticationPrincipal MemberUserDetails memberUserDetails
    ) {
        try {
            UploadAlbumRequest request = objectMapper.readValue(metadata, UploadAlbumRequest.class);
            UploadAlbumCommand command = request.toCommand(coverImage, tracks,memberUserDetails.getMemberId());
            UploadAlbumResponse response = musicService.uploadAlbum(command);

            return ApiUtils.success(response);
        } catch (Exception e) {
            log.error("음원 업로드 중 오류 발생", e);
            return ApiUtils.error(ErrorCode.MUSIC_FORMAT_UNSUPPORTED);
        }
    }


}
