//
//  Models.swift
//  Flava
//
//  Created by eunsang lee on 18/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import Foundation

struct BadRequest: Codable {
    let ok: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case ok
        case message
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.ok = try valueContainer.decode(Bool.self, forKey: CodingKeys.ok)
        self.message = try valueContainer.decode(String.self, forKey: CodingKeys.message)
    }
}

struct Unauthorized: Codable {
    let ok: Bool
    let pattern: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case ok
        case pattern
        case message
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.ok = try valueContainer.decode(Bool.self, forKey: CodingKeys.ok)
        self.pattern = try valueContainer.decode(Int.self, forKey: CodingKeys.pattern)
        self.message = try valueContainer.decode(String.self, forKey: CodingKeys.message)
    }
}

struct Forbidden: Codable {
    let ok: Bool
    let pattern: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case ok
        case pattern
        case message
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.ok = try valueContainer.decode(Bool.self, forKey: CodingKeys.ok)
        self.pattern = try valueContainer.decode(Int.self, forKey: CodingKeys.pattern)
        self.message = try valueContainer.decode(String.self, forKey: CodingKeys.message)
    }
}

struct Ok<T: Codable>: Codable {
    let ok: Bool
    let message: String
    let data: T?
    
    enum CodingKeys: String, CodingKey {
        case ok
        case message
        case data
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.ok = try valueContainer.decode(Bool.self, forKey: CodingKeys.ok)
        self.message = try valueContainer.decode(String.self, forKey: CodingKeys.message)
        self.data = try? valueContainer.decode(T.self, forKey: CodingKeys.data)
    }
}

struct BaseModel {
    struct Avatar: Codable {
        let id: Int
        let is_blocked: Bool
        let is_confirmed: Bool
        let email: String
        let first_name: String
        let last_name: String
        let ph_number: String?
        let color_code: Int
        let introudction: String?
        let date_of_birth: String?
        let photo_name: String?
        let free_exp_date: String
        let is_free_trial: Bool
        let access_token: String?
        let refresh_token: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case is_blocked
            case is_confirmed
            case email
            case first_name
            case last_name
            case ph_number
            case color_code
            case introudction
            case date_of_birth
            case free_exp_date
            case is_free_trial
            case photo_name
            case access_token
            case refresh_token
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
            self.is_blocked = try valueContainer.decode(Bool.self, forKey: CodingKeys.is_blocked)
            self.is_confirmed = try valueContainer.decode(Bool.self, forKey: CodingKeys.is_confirmed)
            self.email = try valueContainer.decode(String.self, forKey: CodingKeys.email)
            self.first_name = try valueContainer.decode(String.self, forKey: CodingKeys.first_name)
            self.last_name = try valueContainer.decode(String.self, forKey: CodingKeys.last_name)
            self.ph_number = try? valueContainer.decode(String.self, forKey: CodingKeys.ph_number)
            self.color_code = try valueContainer.decode(Int.self, forKey: CodingKeys.color_code)
            self.introudction = try? valueContainer.decode(String.self, forKey: CodingKeys.introudction)
            self.date_of_birth = try? valueContainer.decode(String.self, forKey: CodingKeys.date_of_birth)
            self.free_exp_date = try valueContainer.decode(String.self, forKey: CodingKeys.free_exp_date)
            self.is_free_trial = try valueContainer.decode(Bool.self, forKey: CodingKeys.is_free_trial)
            self.photo_name = try? valueContainer.decode(String.self, forKey: CodingKeys.photo_name)
            self.access_token = try? valueContainer.decode(String.self, forKey: CodingKeys.access_token)
            self.refresh_token = try? valueContainer.decode(String.self, forKey: CodingKeys.refresh_token)
        }
    }
    
    struct AvatarCond: Codable {
        let id: Int
        let avatar_id: Int
        let tag_id: Int
        let start_date: String?
        let end_date: String?
        let eng_name: String
        let kor_name: String?
        let jpn_name: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case avatar_id
            case tag_id
            case start_date
            case end_date
            case eng_name
            case kor_name
            case jpn_name
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
            self.avatar_id = try valueContainer.decode(Int.self, forKey: CodingKeys.avatar_id)
            self.tag_id = try valueContainer.decode(Int.self, forKey: CodingKeys.tag_id)
            self.start_date = try? valueContainer.decode(String.self, forKey: CodingKeys.start_date)
            self.end_date = try? valueContainer.decode(String.self, forKey: CodingKeys.end_date)
            self.eng_name = try valueContainer.decode(String.self, forKey: CodingKeys.eng_name)
            self.kor_name = try? valueContainer.decode(String.self, forKey: CodingKeys.kor_name)
            self.jpn_name = try? valueContainer.decode(String.self, forKey: CodingKeys.jpn_name)
        }
    }
    
    struct Banner: Codable {
        let id: Int
        let img_name: String?
        let bg_color: String?
        let txt_color: String?
        let eng_title: String
        let kor_title: String?
        let jpn_title: String?
        let eng_subtitle: String
        let kor_subtitle: String?
        let jpn_subtitle: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case img_name
            case bg_color
            case txt_color
            case eng_title
            case kor_title
            case jpn_title
            case eng_subtitle
            case kor_subtitle
            case jpn_subtitle
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
            self.img_name = try? valueContainer.decode(String.self, forKey: CodingKeys.img_name)
            self.bg_color = try? valueContainer.decode(String.self, forKey: CodingKeys.bg_color)
            self.txt_color = try? valueContainer.decode(String.self, forKey: CodingKeys.txt_color)
            self.eng_title = try valueContainer.decode(String.self, forKey: CodingKeys.eng_title)
            self.kor_title = try? valueContainer.decode(String.self, forKey: CodingKeys.kor_title)
            self.jpn_title = try? valueContainer.decode(String.self, forKey: CodingKeys.jpn_title)
            self.eng_subtitle = try valueContainer.decode(String.self, forKey: CodingKeys.eng_subtitle)
            self.kor_subtitle = try? valueContainer.decode(String.self, forKey: CodingKeys.kor_subtitle)
            self.jpn_subtitle = try? valueContainer.decode(String.self, forKey: CodingKeys.jpn_subtitle)
        }
    }
    
    struct Bookmark: Codable {
        let id: Int
        let tag_id: Int
        let eng_name: String
        let kor_name: String?
        let jpn_name: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case tag_id
            case eng_name
            case kor_name
            case jpn_name
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
            self.tag_id = try valueContainer.decode(Int.self, forKey: CodingKeys.tag_id)
            self.eng_name = try valueContainer.decode(String.self, forKey: CodingKeys.eng_name)
            self.kor_name = try? valueContainer.decode(String.self, forKey: CodingKeys.kor_name)
            self.jpn_name = try? valueContainer.decode(String.self, forKey: CodingKeys.jpn_name)
        }
    }
    
    struct LogGroup: Codable {
        let id: Int
        let year_number: Int
        let year_forweekofyear: Int
        let month_number: Int
        let week_of_year: Int
        let day_of_year: Int
        let group_type: Int
        let food_cnt: Int
        let act_cnt: Int
        let drug_cnt: Int
        let cond_score: Int?
        let note: String?
        let day_number: Int
        
        enum CodingKeys: String, CodingKey {
            case id
            case year_number
            case year_forweekofyear
            case month_number
            case week_of_year
            case day_of_year
            case group_type
            case food_cnt
            case act_cnt
            case drug_cnt
            case cond_score
            case note
            case day_number
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
            self.year_number = try valueContainer.decode(Int.self, forKey: CodingKeys.year_number)
            self.year_forweekofyear = try valueContainer.decode(Int.self, forKey: CodingKeys.year_forweekofyear)
            self.month_number = try valueContainer.decode(Int.self, forKey: CodingKeys.month_number)
            self.week_of_year = try valueContainer.decode(Int.self, forKey: CodingKeys.week_of_year)
            self.day_of_year = try valueContainer.decode(Int.self, forKey: CodingKeys.day_of_year)
            self.group_type = try valueContainer.decode(Int.self, forKey: CodingKeys.group_type)
            self.food_cnt = try valueContainer.decode(Int.self, forKey: CodingKeys.food_cnt)
            self.act_cnt = try valueContainer.decode(Int.self, forKey: CodingKeys.act_cnt)
            self.drug_cnt = try valueContainer.decode(Int.self, forKey: CodingKeys.drug_cnt)
            self.cond_score = try? valueContainer.decode(Int.self, forKey: CodingKeys.cond_score)
            self.note = try? valueContainer.decode(String.self, forKey: CodingKeys.note)
            self.day_number = try valueContainer.decode(Int.self, forKey: CodingKeys.day_number)
        }
    }
    
    struct ProfileTag: Codable {
        let id: Int
        let tag_id: Int
        let is_selected: Bool
        let eng_name: String
        let kor_name: String?
        let jpn_name: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case tag_id
            case is_selected
            case eng_name
            case kor_name
            case jpn_name
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
            self.tag_id = try valueContainer.decode(Int.self, forKey: CodingKeys.tag_id)
            self.is_selected = try valueContainer.decode(Bool.self, forKey: CodingKeys.is_selected)
            self.eng_name = try valueContainer.decode(String.self, forKey: CodingKeys.eng_name)
            self.kor_name = try? valueContainer.decode(String.self, forKey: CodingKeys.kor_name)
            self.jpn_name = try? valueContainer.decode(String.self, forKey: CodingKeys.jpn_name)
        }
    }
    
    struct Tag: Codable {
        let id: Int
        let idx: Int?
        let tag_type: Int?
        let eng_name: String
        let kor_name: String?
        let jpn_name: String?
        let bookmark_id: Int?  // Determining whether it has been bookmarked.
        let class1: Int?
        let division1: Int?
        let division2: Int?
        let division3: Int?
        let division4: Int?
        let division5: Int?
        
        enum CodingKeys: String, CodingKey {
            case id
            case idx
            case tag_type
            case eng_name
            case kor_name
            case jpn_name
            case bookmark_id
            case class1
            case division1
            case division2
            case division3
            case division4
            case division5
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
            self.idx = try? valueContainer.decode(Int.self, forKey: CodingKeys.idx)
            self.tag_type = try? valueContainer.decode(Int.self, forKey: CodingKeys.tag_type)
            self.eng_name = try valueContainer.decode(String.self, forKey: CodingKeys.eng_name)
            self.kor_name = try? valueContainer.decode(String.self, forKey: CodingKeys.kor_name)
            self.jpn_name = try? valueContainer.decode(String.self, forKey: CodingKeys.jpn_name)
            self.bookmark_id = try? valueContainer.decode(Int.self, forKey: CodingKeys.bookmark_id)
            self.class1 = try? valueContainer.decode(Int.self, forKey: CodingKeys.class1)
            self.division1 = try? valueContainer.decode(Int.self, forKey: CodingKeys.division1)
            self.division2 = try? valueContainer.decode(Int.self, forKey: CodingKeys.division2)
            self.division3 = try? valueContainer.decode(Int.self, forKey: CodingKeys.division3)
            self.division4 = try? valueContainer.decode(Int.self, forKey: CodingKeys.division4)
            self.division5 = try? valueContainer.decode(Int.self, forKey: CodingKeys.division5)
        }
    }
    
    struct TagLog: Codable {
        let id: Int
        let group_id: Int
        let tag_id: Int
        let tag_type: Int
        let x_val: Int?
        let y_val: Int?
        let eng_name: String
        let kor_name: String?
        let jpn_name: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case group_id
            case tag_id
            case tag_type
            case x_val
            case y_val
            case eng_name
            case kor_name
            case jpn_name
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try valueContainer.decode(Int.self, forKey: CodingKeys.id)
            self.group_id = try valueContainer.decode(Int.self, forKey: CodingKeys.group_id)
            self.tag_id = try valueContainer.decode(Int.self, forKey: CodingKeys.tag_id)
            self.tag_type = try valueContainer.decode(Int.self, forKey: CodingKeys.tag_type)
            self.x_val = try? valueContainer.decode(Int.self, forKey: CodingKeys.x_val)
            self.y_val = try? valueContainer.decode(Int.self, forKey: CodingKeys.y_val)
            self.eng_name = try valueContainer.decode(String.self, forKey: CodingKeys.eng_name)
            self.kor_name = try? valueContainer.decode(String.self, forKey: CodingKeys.kor_name)
            self.jpn_name = try? valueContainer.decode(String.self, forKey: CodingKeys.jpn_name)
        }
    }
}

struct CustomModel {
    struct Auth: Codable {
        let avatar: BaseModel.Avatar
        let language_id: Int
        
        enum CodingKeys: String, CodingKey {
            case avatar
            case language_id
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.avatar = try valueContainer.decode(BaseModel.Avatar.self, forKey: CodingKeys.avatar)
            self.language_id = try valueContainer.decode(Int.self, forKey: CodingKeys.language_id)
        }
    }
    
    struct Profile: Codable {
        let avatar: BaseModel.Avatar
        let language_id: Int
        let profile_tags: [BaseModel.ProfileTag]
        
        enum CodingKeys: String, CodingKey {
            case avatar
            case language_id
            case profile_tags
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.avatar = try valueContainer.decode(BaseModel.Avatar.self, forKey: CodingKeys.avatar)
            self.language_id = try valueContainer.decode(Int.self, forKey: CodingKeys.language_id)
            self.profile_tags = try valueContainer.decode([BaseModel.ProfileTag].self, forKey: CodingKeys.profile_tags)
        }
    }
    
    struct ProfileTagSet: Codable {
        let sub_tags: [BaseModel.Tag]
        let select_idx: Int
        
        enum CodingKeys: String, CodingKey {
            case sub_tags
            case select_idx
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.sub_tags = try valueContainer.decode([BaseModel.Tag].self, forKey: CodingKeys.sub_tags)
            self.select_idx = try valueContainer.decode(Int.self, forKey: CodingKeys.select_idx)
        }
    }
    
    struct PostBookmark: Codable {
        let bookmark_id: Int
        let bookmarks_total: Int
        
        enum CodingKeys: String, CodingKey {
            case bookmark_id
            case bookmarks_total
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.bookmark_id = try valueContainer.decode(Int.self, forKey: CodingKeys.bookmark_id)
            self.bookmarks_total = try valueContainer.decode(Int.self, forKey: CodingKeys.bookmarks_total)
        }
    }
    
    struct GroupOfLogSet: Codable {
        let group_id: Int
        var food_logs: [BaseModel.TagLog]?
        var act_logs: [BaseModel.TagLog]?
        var drug_logs: [BaseModel.TagLog]?
        let cond_score: Int?
        
        enum CodingKeys: String, CodingKey {
            case group_id
            case food_logs
            case act_logs
            case drug_logs
            case cond_score
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.group_id = try valueContainer.decode(Int.self, forKey: CodingKeys.group_id)
            self.food_logs = try? valueContainer.decode([BaseModel.TagLog].self, forKey: CodingKeys.food_logs)
            self.act_logs = try? valueContainer.decode([BaseModel.TagLog].self, forKey: CodingKeys.act_logs)
            self.drug_logs = try? valueContainer.decode([BaseModel.TagLog].self, forKey: CodingKeys.drug_logs)
            self.cond_score = try? valueContainer.decode(Int.self, forKey: CodingKeys.cond_score)
        }
    }
    
    struct LogGroupSection {
        let dayOfYear: Int
        let logGroup: BaseModel.LogGroup
    }
    
    struct AvgCondScoreSet: Codable {
        let this_avg_score: String
        let last_avg_score: String?
        
        enum CodingKeys: String, CodingKey {
            case this_avg_score
            case last_avg_score
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.this_avg_score = try valueContainer.decode(String.self, forKey: CodingKeys.this_avg_score)
            self.last_avg_score = try? valueContainer.decode(String.self, forKey: CodingKeys.last_avg_score)
        }
    }
    
    struct ScoreBoardSet: Codable {
        let avg_score: String
        let date_of_birth: String?
        let gender_tag: BaseModel.Tag?
        
        enum CodingKeys: String, CodingKey {
            case avg_score
            case date_of_birth
            case gender_tag
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.avg_score = try valueContainer.decode(String.self, forKey: CodingKeys.avg_score)
            self.date_of_birth = try? valueContainer.decode(String.self, forKey: CodingKeys.date_of_birth)
            self.gender_tag = try? valueContainer.decode(BaseModel.Tag.self, forKey: CodingKeys.gender_tag)
        }
    }
    
    struct TagSet: Codable {
        let tag: BaseModel.Tag
        let sub_tags: [BaseModel.Tag]
        let bookmark_id: Int?
        let bookmarks_total: Int?
        
        enum CodingKeys: String, CodingKey {
            case tag
            case sub_tags
            case bookmark_id
            case bookmarks_total
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.tag = try valueContainer.decode(BaseModel.Tag.self, forKey: CodingKeys.tag)
            self.sub_tags = try valueContainer.decode([BaseModel.Tag].self, forKey: CodingKeys.sub_tags)
            self.bookmark_id = try? valueContainer.decode(Int.self, forKey: CodingKeys.bookmark_id)
            self.bookmarks_total = try? valueContainer.decode(Int.self, forKey: CodingKeys.bookmarks_total)
        }
    }
    
    struct Ranking: Codable {
        let avatar_id: Int
        let first_name: String
        let last_name: String
        let color_code: Int
        let introudction: String?
        let date_of_birth: String?
        let photo_name: String?
        let rank_num: Int
        let full_lifespan: Int?
        
        enum CodingKeys: String, CodingKey {
            case avatar_id
            case first_name
            case last_name
            case color_code
            case introudction
            case date_of_birth
            case photo_name
            case rank_num
            case full_lifespan
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.avatar_id = try valueContainer.decode(Int.self, forKey: CodingKeys.avatar_id)
            self.first_name = try valueContainer.decode(String.self, forKey: CodingKeys.first_name)
            self.last_name = try valueContainer.decode(String.self, forKey: CodingKeys.last_name)
            self.color_code = try valueContainer.decode(Int.self, forKey: CodingKeys.color_code)
            self.introudction = try? valueContainer.decode(String.self, forKey: CodingKeys.introudction)
            self.date_of_birth = try? valueContainer.decode(String.self, forKey: CodingKeys.date_of_birth)
            self.photo_name = try? valueContainer.decode(String.self, forKey: CodingKeys.photo_name)
            self.rank_num = try valueContainer.decode(Int.self, forKey: CodingKeys.rank_num)
            self.full_lifespan = try? valueContainer.decode(Int.self, forKey: CodingKeys.full_lifespan)
        }
    }
    
    struct RankingSet: Codable {
        let rankings: [CustomModel.Ranking]
        
        enum CodingKeys: String, CodingKey {
            case rankings
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.rankings = try valueContainer.decode([CustomModel.Ranking].self, forKey: CodingKeys.rankings)
        }
    }
    
    struct RemainingLifespanSet: Codable {
        let avg_score: String
        let r_lifespan_day: Int
        
        enum CodingKeys: String, CodingKey {
            case avg_score
            case r_lifespan_day
        }
        
        init(from decoder: Decoder) throws {
            let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.avg_score = try valueContainer.decode(String.self, forKey: CodingKeys.avg_score)
            self.r_lifespan_day = try valueContainer.decode(Int.self, forKey: CodingKeys.r_lifespan_day)
        }
    }
}
