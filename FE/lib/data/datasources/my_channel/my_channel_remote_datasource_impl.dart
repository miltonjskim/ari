import 'package:dio/dio.dart';
import '../../../core/exceptions/failure.dart';
import '../../models/api_response.dart';
import '../../models/my_channel/channel_info.dart';
import '../../models/my_channel/artist_album.dart';
import '../../models/my_channel/artist_notice.dart';
import '../../models/my_channel/fantalk.dart';
import '../../models/my_channel/public_playlist.dart';
import '../../models/my_channel/neighbor.dart';
import 'my_channel_remote_datasource.dart';

/// 나의 채널 관련 API 호출 실제로! 수행
/// Dio -> HTTP 요청 -> 서버로부터 This 데이터를 받아오고 모델로 변환
class MyChannelRemoteDataSourceImpl implements MyChannelRemoteDataSource {
  /// Dio HTTP 클라이언트
  final Dio dio;

  /// [dio] : Dio HTTP 클라이언트 객체
  /// 인증 인터셉터 설정된 dio 객체 사용
  MyChannelRemoteDataSourceImpl({required this.dio}) {
    // 기본 URL과 타임아웃 설정은 Provider에서 이미 설정되었음
    // 인증 토큰은 AuthInterceptor에서 자동으로 헤더에 추가됨
  }

  /// API 요청 처리, 결과를 반환
  Future<T> _request<T>({
    required String url,
    required String method,
    required T Function(dynamic) fromJson,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      Response response;

      switch (method) {
        case 'GET':
          response = await dio.get(url, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await dio.post(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'DELETE':
          response = await dio.delete(url, queryParameters: queryParameters);
          break;
        default:
          throw Failure(message: '지원하지 않는 HTTP 메서드입니다: $method');
      }

      // API 응답 처리
      final apiResponse = ApiResponse.fromJson(response.data, fromJson);

      // 오류 check
      if (apiResponse.error != null) {
        throw Failure(
          message: apiResponse.error?.message ?? 'Unknown error',
          code: apiResponse.error?.code,
          statusCode: apiResponse.status,
        );
      }

      // 응답 데이터 반환
      return apiResponse.data as T;
    } on DioException catch (e) {
      throw Failure(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw Failure(message: '😞알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 채널 정보 조회
  /// API 응답 형식: { memberId, memberName, profileImageUrl, subscriberCount, followedYn, fantalkChannelId }
  @override
  Future<ChannelInfo> getChannelInfo(String memberId) async {
    return _request<ChannelInfo>(
      url: '/api/v1/members/$memberId/channel-info', // API 엔드포인트 수정
      method: 'GET',
      fromJson: (data) {
        // 백엔드 API 응답에 memberId가 없어서 파라미터로 받은 값을 사용
        if (data is Map<String, dynamic> && !data.containsKey('memberId')) {
          data['memberId'] = memberId;
        }

        if (data is Map<String, dynamic> && data.containsKey('followedYn')) {
          data['isFollowed'] = data['followedYn'];
        }

        return ChannelInfo.fromJson(data);
      },
    );
  }

  /// 회원 팔로우
  @override
  Future<void> followMember(String memberId) async {
    await _request<void>(
      url: '/api/v1/follows/members/$memberId',
      method: 'POST',
      fromJson: (_) {}, // 데이터 없으므로 null 반환
    );
  }

  /// 회원 언팔로우
  @override
  Future<void> unfollowMember(String memberId) async {
    await _request<void>(
      url: '/api/v1/follows/members/$memberId',
      method: 'DELETE',
      fromJson: (_) {}, // 데이터 없으므로 null 반환
    );
  }

  /// 아티스트 앨범 목록 조회
  @override
  Future<List<ArtistAlbum>> getArtistAlbums(String memberId) async {
    return _request<List<ArtistAlbum>>(
      url: '/api/v1/artists/$memberId/albums',
      method: 'GET',
      fromJson: (data) {
        // API 응답에서 앨범 배열을 직접 파싱
        if (data is List) {
          return data
              .map((albumJson) => ArtistAlbum.fromJson(albumJson))
              .toList();
        } else {
          print('❌ 앨범 데이터 파싱 중 예상치 못한 형식: ${data.runtimeType}, $data');
          return [];
        }
      },
    );
  }

  /// 아티스트 공지사항 조회
  @override
  Future<ArtistNoticeResponse> getArtistNotices(String memberId) async {
    return _request<ArtistNoticeResponse>(
      url: '/api/v1/artists/$memberId/notices',
      method: 'GET',
      fromJson: (data) => ArtistNoticeResponse.fromJson(data),
    );
  }

  /// 팬톡 목록 조회
  @override
  Future<FanTalkResponse> getFanTalks(String fantalkChannelId) async {
    return _request<FanTalkResponse>(
      url: '/api/v1/fantalk-channels/$fantalkChannelId/fantalks',
      method: 'GET',
      fromJson: (data) => FanTalkResponse.fromJson(data),
    );
  }

  /// 공개된 플레이리스트 조회
  @override
  Future<PublicPlaylistResponse> getPublicPlaylists(String memberId) async {
    return _request<PublicPlaylistResponse>(
      url: '/api/v1/playlists/$memberId/public',
      method: 'GET',
      fromJson: (data) => PublicPlaylistResponse.fromJson(data),
    );
  }

  /// 팔로워 목록 조회
  @override
  Future<FollowerResponse> getFollowers(String memberId) async {
    return _request<FollowerResponse>(
      url: '/api/v1/follows/members/$memberId/follower/list',
      method: 'GET',
      fromJson: (data) => FollowerResponse.fromJson(data),
    );
  }

  /// 팔로잉 목록 조회
  @override
  Future<FollowingResponse> getFollowings(String memberId) async {
    return _request<FollowingResponse>(
      url: '/api/v1/follows/members/$memberId/following/list',
      method: 'GET',
      fromJson: (data) => FollowingResponse.fromJson(data),
    );
  }
}
